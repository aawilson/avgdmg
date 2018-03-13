# Avgdmg

A bot for parsing strings that describe lists of attacks against an AC, and then calculating the average damage against that AC. Right now, it is only implemented for Discord, but implementing other chat programs is as easy as adding a new subproject that makes a GenStage producer in a format recognized by AvgdmgStage.Worker, then another consumer that consumes the format produced by that worker (see avgdmg_discord/lib/avgdmg_discord/application.ex for how it's arranged with Discord).


Strings can be of the format: `<attack expression> with <options expression> vs <integer or range> [ac]`

where `<attack expression>` is either `<dice expression> [, <dice expression>]` or `<Attack description>: <dice expression>`, `<options expression>` is `[option [other option]]` and `option` is `[dis]advantage` and some other stuff that might only be implemented in a branch right now, I have to double-check.
