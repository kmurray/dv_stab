library verilog;
use verilog.vl_types.all;
entity sum_of_64 is
    port(
        data            : in     vl_logic_vector(63 downto 0);
        sum             : out    vl_logic_vector(6 downto 0)
    );
end sum_of_64;
