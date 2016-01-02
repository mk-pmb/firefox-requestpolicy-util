
Cross-domain ACL configs
========================
(File format version: 1)

They're text files. The __charset__ defaults to UTF-8.
The first things in the file, although both optional, should be a UTF-8 BOM
and the __file format identifier__ of `#cross-domain-acl#`.

Each line may be empty, contain an access rule or be a line comment.


Inoperative additives
---------------------
__Whitespace__ at start or end of lines is to be ignored.
Whitespace inside a line is __merged__, so any (non-empty) combination of
spaces and/or tabs is to be parsed as one space character,
but it's encouraged to preserve the original combination when writing files.
(Of course, user preferences are more important, especially if a program is
capable of helping users align blocks/columns for easier reading.)

__Line comments__ start with `#`, `//` or `;`.

__Line continuation__: Any line that is not a line comment can be continuated
in the next line by appending a backslash (`\`). Remember that whitespace after
that backslash, and at start of the next line, is ignored as described above.
If the line to be appended is a line comment, it might be appended, skipped,
or treated as empty.


Access Rules
------------
__Access rules__ are in one of these formats:
```text
[origin]      [space]         [arrow] [space] [destination]
[destination] [space] [reverse arrow] [space] [origin]
```

Available arrows (and reverse forms):
  * `->` (`<-`): allow access
  * `->!` (`!<-`): deny access — position mnemonic: run into a wall.

Arrows will never contain spaces even in future versions, but hosts can,
so best parse the arrows first.

__Hosts (origin/destination)__ formats can be:
  * a hostname (e.g. `host.tld`, `sub.host.tld`),
  * a wildcard hostname, where the left-most label is `*`
    (e.g. `*.host.tld`, `*.tld` or even just `*`)
  * Protocol schemes like `file://` or `git+ssh://`.
    Characters supported in protocol names:
    `a`..`z`, `0`..`9`, `+`, `-`
    * (In `rqpol-genwl.sh`, `PROTOCOL_SCHEMES_RGX` should conform to this.)
  * a composite form for easier sorting:
    * `host.tld*` = `*.host.tld` — trailing wildcard,
      notice the dot is added.
    * `host.tld ^sub.` = `sub.host.tld` — trailing prefix,
      don't forget the dot if you want one.


Details on trailing prefixes
----------------------------
  * They cannot be empty. Counter-example: `-trailing.prefix ^ ^not-a`
  * `host.tld ^*.` = `*.host.tld` — don't forget the dot if you want one.
  * Multiple trailing prefixes are added in reverse order:
    * `host.tld ^cdn. ^pics.` = `pics.cdn.host.tld`
  * They aren't limited to label bounds, so they don't need to end with a dot.
    * `host.tld ^cdn. ^pics-` = `pics-cdn.host.tld`
    * Yes, it does go `n ^e ^v ^e ^l ^e ^. ^o ^t ^. ^p ^u`
      = `up.to.eleven`. No upper limit.


