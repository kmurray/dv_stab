library verilog;
use verilog.vl_types.all;
entity correlator_xor is
    generic(
        RESET           : integer := 0;
        PREV_ADDR       : integer := 1;
        LD_PREV         : integer := 2;
        CURR_ADDR       : integer := 3;
        LD_CURR         : integer := 4;
        OFFSET_X        : integer := 5;
        LINE_SUM        : integer := 6;
        \DONE\          : integer := 7
    );
    port(
        clk             : in     vl_logic;
        resetn          : in     vl_logic;
        go              : in     vl_logic;
        bram_data       : in     vl_logic_vector(127 downto 0);
        bram_addr       : out    vl_logic_vector(8 downto 0);
        x_offset        : in     vl_logic_vector(5 downto 0);
        y_offset        : in     vl_logic_vector(5 downto 0);
        curr_frame_bram_offset_sel: in     vl_logic;
        corr_sum        : out    vl_logic_vector(15 downto 0);
        done            : out    vl_logic
    );
end correlator_xor;
