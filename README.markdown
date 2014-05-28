This project contains three scripts to help working with the
steam-runtime, especially outside of Steam.

See these blog posts for more details:

 * [steam-runtime without Steam][no-steam-post]
 * [Self-contained game distribution on Linux][self-contained-linux-post]

## update_runtime.sh

[A script to download the runtime][update], but only if it has been
updated since last time.

## extract_runtime.sh

[A script to extract the important bits of the runtime][extract],
skipping the huge amount of documentation present (and optionally, the
binaries for irrelevant architectures.)

## launch_wrapper.sh

[A simple launcher script for your game][launch] to ensure your game
executes inside the steam-runtime, and to aid in running it under gdb.

[no-steam-post]: http://jorgen.tjer.no/post/2014/05/28/steam-runtime-without-steam/
[self-contained-linux-post]: http://jorgen.tjer.no/post/2014/05/26/self-contained-game-distribution-on-linux/
[update]: update_runtime.sh
[extract]: extract_runtime.sh
[launch]: launc_wrapper.sh
