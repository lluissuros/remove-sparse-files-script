# remove-sparse-files-script
### remove sparse files script, specially on Logic
Some audio files are recorded reserving 2 GB of space — this crashes my computer.

You can identify them with:
```bash
find ~/Music/Logic -type f -exec du -h {} + | sort -hr | head -n 30
```


This script scans the current folder for sparse audio files (files whose disk usage is much higher than their logical size), then:

Replaces them with clean copies (same name, no disk bloat).

Moves the original files to a sparse/ folder, renamed with a __sparse suffix.

Shows disk usage before and after cleanup.

Asks whether to delete the sparse/ folder at the end.

✅ How to use:
```bash
chmod +x clean_sparse_restore_and_finalize.sh
./clean_sparse_restore_and_finalize.sh
```

No changes are made until you confirm with Y.


Hay algunos audios que se grban rservando 2 GB, esto me peta el ordenador

se identifican asi:
find ~/Music/Logic -type f -exec du -h {} + | sort -hr | head -n 30


