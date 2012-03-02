library verilog;
use verilog.vl_types.all;
entity twelve_four_comp is
    port(
        data            : in     vl_logic_vector(11 downto 0);
        sum             : out    vl_logic_vector(3 downto 0)
    );
end twelve_four_comp;
