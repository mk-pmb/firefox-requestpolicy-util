#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$0"/..)"


function rqpol_genwl () {
  local RULE_FILES=( "$@" )
  [ -n "${RULE_FILES[*]}" ] || RULE_FILES=( *.rqp )
  local RULES_ARRAYS="$(rqpol_genwl_rules_arrays "${RULE_FILES[@]}")"
  rqpol_genwl_render_json | "$SELFPATH"/rqpol-sort.py
  return $?
}


function rqpol_genwl_render_json () {
  echo '{ "entries": {'
  local EMPTY_ARRAY=
  for EMPTY_ARRAY in allow deny; do
    EMPTY_ARRAY='  "'"$EMPTY_ARRAY"'": ['
    <<<"$RULES_ARRAYS" grep -qxFe "$EMPTY_ARRAY" || echo "$EMPTY_ARRAY],"
  done
  echo "$RULES_ARRAYS"
  echo '}, "metadata": { "generator": "rqpol_genwl", "version": 1 } }'
}


function rqpol_genwl_rules_arrays () {
  sed -re '
    s~\s+~ ~g;s~^ ~~;s~ $~~
    \~^ ?(#|//|;)~d
    s~^(.*) (!?) ?<- (.*)$~\3 ->\2 \1~
    s~^(.* ->) ?!~! \1~
    / -> /!d
    s~ -> ~\t~
    / -> /d
    s~^(!?) ?~\1\t~
    s~^\t~allow\t~
    s~^!\t~deny\t~
    ' -- "$@" | sort -V | sed -re '
    : decode
      s~(^|\t)(\S+)\*(\t|$)~\1*.\2\3~g
      s~(^|\t)(\S+) \^(\S+)(\s|$)~\1\3\2\4~g
    t decode
    s~^(\w+)(\s).*$~<&\r\1>~
    ' | tr '\r\n' '\n ' | sed -re '
    s~^(\w+)> <(\w+\s)~<>\1:\2~
    s~^<(\w+)\t~  "\1": [\n<>\t~
    s~^<>(\w+):\1\t~<,>\t~
    s~^<>(\w+):(\w+)\s~  ], "\2": [\n<>\t~
    s~^\w+>\s*$~  ]\n~
    ' | sed -re '
    s~^<(,?)>\s+(\S+)\s+(\S+)$~\1    { "o": {"h": "\2"}, "d": {"h": "\3"} }~
    s~(\{ )"o": \{"h": "\*"\}, ~\1~
    s~, "d": \{"h": "\*"\}( \})~\1~
    s~(\{"h": ")(\w+)://("\})~\1", "s": "\2\3~g
    1!{s~^(,?)~\1\r~}
    ' | tr '\r\n' '\n\r' | sed -re 's~\r(,?)$~\1~;s~\r~¶~g'
}



















[ "$1" == --lib ] && return 0; rqpol_genwl "$@"; exit $?
