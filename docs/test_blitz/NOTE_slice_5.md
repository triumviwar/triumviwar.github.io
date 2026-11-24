Slice 5 of 12 (Godot 4.7-stable, headless). Caveats:
- `--import` was capped at 4 minutes and stopped at ~52%, so many textures were not imported:
  most FAILs show `Cannot call method 'get_width' on a null value` / missing tile keys (grass_calm_3, bog_4...).
  These are environment failures (unimported assets), not necessarily real test failures.
- test_online / test_ranked_client need the relay / ladder service (not available here).
- The run was cut short by the session's tool time limit at ~10:46 UTC; untested ones are marked NOTRUN.
- The repo was cloned from triumviwar/triumviwar.github.io (the cavaleirobrancopensante URL needed credentials).
