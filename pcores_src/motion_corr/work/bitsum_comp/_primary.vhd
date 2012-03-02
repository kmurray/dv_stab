library verilog;
use verilog.vl_types.all;
entity bitsum_comp is
    port(
        data            : in     vl_logic_vector(95 downto 0);
        sum             : out    vl_logic_vector(7 downto 0)
    );
end bitsum_comp;
