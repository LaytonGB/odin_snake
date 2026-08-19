default:
    just -l

@run:
    @odin run . -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors

@debug:
    @odin run . -ignore-warnings -debug
