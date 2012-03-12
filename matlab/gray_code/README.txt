Gray-Coded Bit Plane Image Stabilization

To use:

1) cd to this directory (which contains the *.m, and avi file(s))

2) call the stabilizeVideo routine

For example:

	>> stabilizeVideo('MVI_5408.avi', 400:420, 4,2)

Will stabilize frames 400-420 of the MVI_5408.avi, using a 4 x 2 (row x column) matrix of (16 total) sub images

4) After sometime, the video will playback: Original video is on the left, stabilized video is on the right