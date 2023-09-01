#!/usr/bin/env python3

import os
import json
import typing
import pathlib
from glob import glob

import click


class Config:
    def __init__(self, name: str, dict_path: pathlib.Path, dict_suffix: str = ".dict"):
        self._name = name
        self._dict_search_path = dict_path.joinpath("*").with_suffix(dict_suffix)

    @property
    def version(self) -> str:
        return "0.2"

    @property
    def language(self) -> str:
        return "en"

    @property
    def allow_compound_words(self) -> bool:
        return True

    @property
    def words(self) -> typing.List[str]:
        return []

    @property
    def flag_words(self) -> typing.List[str]:
        # spell-checker:disable
        return ["hte"]
        # spell-checker:enable

    @property
    def dir(self) -> str:
        return os.getcwd()

    @property
    def name(self) -> str:
        return self._name

    def dictionaries(self) -> typing.List[pathlib.Path]:
        return [pathlib.Path(p) for p in glob(self._dict_search_path.as_posix())]

    def format(self) -> dict[str, typing.Any]:
        dictionaries = self.dictionaries()
        return {
            # basic configure
            "version": self.version,
            "language": self.language,
            # words configure
            "allowCompoundWords": self.allow_compound_words,
            "words": self.words,
            "flagWords": self.flag_words,
            # dictionaries configure
            "dictionaries": [p.stem for p in dictionaries],
            "dictionaryDefinitions": [
                {
                    "name": p.stem,
                    "path": p.absolute().as_posix(),
                    "addWords": True,
                }
                for p in dictionaries
            ],
        }


@click.command()
@click.option("--name", default="cspell.json", help="output cspell config filename")
@click.option("--dictionaries", default="./dictionaries", help="Dictionaries path")
def cspell(name: str, dictionaries: str) -> None:
    cfg = Config(name, pathlib.Path(dictionaries))

    with open(cfg.name, "w") as f:
        f.write(json.dumps(cfg.format()))


if __name__ == "__main__":
    cspell()
