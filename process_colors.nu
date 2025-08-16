use ~/Projects/dotfiles/nushell/modules/ *

let orig_json = open ./anysphere-theme.json
let palette = $orig_json.colors | merge ($orig_json.semanticTokenColors | each value {|v| match ($v | describe) {
    $r if ($r | str starts-with "record") => $v.foreground
    _ => $v
}})

print $palette

# let colors = $palette | items { |k v| $v | str substring 0..6}

# print $colors

# for c in $colors {
#     $c | color show
# }

