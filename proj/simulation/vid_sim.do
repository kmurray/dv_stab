if {( $argc != 2 )} {
    echo "Error: must provide run time and time unit (e.g. '1 ms')"
    abort
}

# Add the ddr dim
echo "Adding dim"
do ../ddr_dimm/add_dimm.do

echo "Adding video images"
do ../videoin/setvideoin.do ../videoin/lenna.png ../videoin/test.png

echo "Compiling"
c

echo "Starting"
s

echo "Config wave window"
w

echo "Running sim for $1 $2"
# $1 should be time time to run
# $2 should be the unit of time
run $1 $2

echo "Grabbing processed image"
do ../imagesim/saveimagedata.do
