
Cross-domain ACL configs
========================
(File format version: 1)

They're text files. The __charset__ defaults to UTF-8.
The first things in the file, although both optional, should be a UTF-8 BOM
and the __file format identifier__ of `#cross-domain-acl#`.

__Whitespace__ at start or end of lines is to be ignored.
Whitespace inside a line is merged, so any (non-empty) combination of spaces
and/or tabs is to be parsed as one space character,
but it's encouraged to preserve the original combination when writing files.
(Of course, user preferences are more important, especially if a program is
capable of helping users align blocks for easier reading.)

Each line may be empty, contain a rule or be a line comment.

__Line comments__ start with `#`, `//` or `;`.

__Rules__ are in one of these formats:
```text
[origin]      [space]         [arrow] [space] [destination]
[destination] [space] [reverse arrow] [space] [origin]
```

Available arrows (and reverse forms):
  * `->` (`<-`): allow access
  * `->!` (`!<-`): deny access

Arrows will never contain spaces even in future versions, but hosts can,
so best parse the arrows first.

__Hosts (origin/destination)__ formats can be:
  * a hostname (e.g. `host.tld`, `sub.host.tld`),
  * a wildcard hostname, where the left-most label is `*`
    (e.g. `*.host.tld`, `*.tld` or even just `*`)
  * Protocol schemes like `file://` or `git+ssh://`.
    Characters supported in protocol names:
    `a`-`z`, `0-9`, `+`, `-`
    (In `rqpol-genwl.sh`, `PROTOCOL_SCHEMES_RGX` should conform to this.)
  * a composite form for easier sorting:
    * `host.tld*` = `*.host.tld` -- trailing wildcard,
      notice the dot is added
    * `host.tld ^sub.` = `sub.host.tld` -- trailing prefix,
      don't forget the dot if you want one.

Details on trailing prefixes
----------------------------
  * They cannot be empty. Counter-example: `not-a-trailing.prefix ^`
  * `host.tld ^*.` = `*.host.tld`
  * Multiple trailing prefixes are added in reverse order:
    * `host.tld ^cdn. ^pics.` = `pics.cdn.host.tld`
  * They aren't limited to label bounds, so they don't need to end with a dot.
    * `host.tld ^cdn. ^pics-` = `pics-cdn.host.tld`
    * Yes, it does go up to `d ^l ^t ^. ^t ^s ^o ^h` = `host.tld`.


