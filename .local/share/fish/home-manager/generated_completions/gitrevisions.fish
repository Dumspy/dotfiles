# gitrevisions
complete -c gitrevisions -l no-checkout -d AUTO_MERGE
complete -c gitrevisions -l since -d and
complete -c gitrevisions -l until -d '<refname>@{<n>}, e. g.  master@{1}'
complete -c gitrevisions -l -A---B---o---o---C---D -d 'because A and B are reachable from C, the revision range specified by these t…'
