-------------------------------------------------------------------------------
-- $Id: xps_tft.vhd,v 1.11.2.5 2008/07/17 11:52:22 pankajk Exp $
-------------------------------------------------------------------------------
-- xps_tft.vhd - entity/architecture pair 
-------------------------------------------------------------------------------
--
--  ***************************************************************************
--  **  Copyright(C) 2008 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:      xps_tft.vhd
-- Version:       v1.00a
-- Description:   Top level design file for XPS TFT controller. It instantiate 
--                PLBv46 maste/slave interface and TFT controller logic. This
--                supports display resolution 640*480 pixels at 25 MHz display
--                clock for 60 Hz TFT refresh rate.
--
-- VHDL-Standard: VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  -- xps_tft.vhd
--                      -- plbv46_master_burst.vhd
--                      -- plbv46_slave_single.vhd
--                      -- tft_controller.v
--                          -- line_buffer.v
--                          -- v_sync.v
--                          -- h_sync.v
--                          -- slave_register.v
--                          -- tft_interface.v
--                              -- iic_init.v
--
-------------------------------------------------------------------------------
-- Change log:
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_K_SP3
--
-- *** xps_tft_v1_00_a  EDK_K_SP3 ***
-- New Features
--  First version of XPS TFT controller
--
-- Resolved Issues
--  Nil
--
-- Known Issues
--  Nil
--
-- Other Information (optional)
--  Nil
-- 
-- @END_CHANGELOG
-------------------------------------------------------------------------------
-- Author:          PVK
-- History:
--  PVK             07/01/08    First Version
-- ^^^^^^^
--  First version of XPS TFT controller.
-- ~~~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- proc common package of the proc common library is used for different 
-- function declarations
-------------------------------------------------------------------------------
library proc_common_v3_00_a;
use proc_common_v3_00_a.ipif_pkg.INTEGER_ARRAY_TYPE;
use proc_common_v3_00_a.ipif_pkg.SLV64_ARRAY_TYPE;
use proc_common_v3_00_a.ipif_pkg.calc_num_ce;
use proc_common_v3_00_a.family.all;
use proc_common_v3_00_a.family_support.all;

-------------------------------------------------------------------------------
-- plbv46_slave_single_v1_01_a library is used for plbv46_slave_single 
-- component declarations
-------------------------------------------------------------------------------
library plbv46_slave_single_v1_01_a;
use plbv46_slave_single_v1_01_a.plbv46_slave_single;

-------------------------------------------------------------------------------
-- plbv46_master_burst_v1_01_a library is used for plbv46_master_burst 
-- component declarations
-------------------------------------------------------------------------------
library plbv46_master_burst_v1_01_a;
use plbv46_master_burst_v1_01_a.plbv46_master_burst;

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
-- Definition of Generics:
--   C_FAMILY                 -- Xilinx FPGA family
--
-- -- TFT Controller Generics
------------------------------------
--   C_DCR_SPLB_SLAVE_IF      -- Specifies TFT slave registers access
--   C_TFT_INTERFACE          -- Specifies TFT display interface (VGA/DVI)
--   C_I2C_SLAVE_ADDR         -- I2C slave address of chrontel chip  
--   C_DEFAULT_TFT_BASE_ADDR  -- TFT Video memory base address
--
-- -- DCR Interface Generics
------------------------------------
--   C_DCR_BASEADDR           -- DCR slave base address
--   C_DCR_HIGHADDR           -- DCR slave high address
--
-- --  PLBv46 Master Burst Interface Generics
------------------------------------
--   C_MPLB_AWIDTH            -- PLBv46 master: address bus width
--   C_MPLB_DWIDTH            -- PLBv46 master: data bus width
--   C_MPLB_NATIVE_DWIDTH     -- PLBv46 master: internal native data width
--   C_MPLB_SMALLEST_SLAVE    -- PLBv46 master: width of the smallest slave
--
-- --  PLBv46 Slave Single Interface Generics
------------------------------------
--   C_SPLB_AWIDTH          -- PLBv46 slave: address bus width
--   C_SPLB_DWIDTH          -- PLBv46 slave: data bus width
--   C_SPLB_P2P             -- PLBv46 slave: point to point 
--                             interconnect scheme
--   C_SPLB_MID_WIDTH       -- PLBv46 slave: master ID bus width
--   C_SPLB_NUM_MASTERS     -- PLBv46 slave: Number of masters
--   C_SPLB_NATIVE_DWIDTH   -- PLBv46 slave: internal native data bus 
--                             width
--   C_SPLB_BASEADDR        -- PLBv46 slave: base address
--   C_SPLB_HIGHADDR        -- PLBv46 slave: high address
--
--
-- Definition of Ports:
-- -- System Interface signals
------------------------------------
--   SPLB_Clk               -- PLB main bus clock
--   SPLB_Rst               -- PLB main bus reset
--   MPLB_Clk               -- PLB main bus Clock
--   MPLB_Rst               -- PLB main bus Reset
--   MD_error               -- Master detected error status output
--
-- -- PLB Master Interface signals
------------------------------------
--   M_request              -- Master request
--   M_priority             -- Master request priority
--   M_busLock              -- Master buslock
--   M_RNW                  -- Master read/nor write
--   M_BE                   -- Master byte enables
--   M_MSize                -- Master data bus size
--   M_size                 -- Master transfer size
--   M_type                 -- Master transfer type
--   M_TAttribute           -- Master transfer attribute
--   M_lockErr              -- Master lock error indicator
--   M_abort                -- Master abort bus request indicator
--   M_UABus                -- Master upper address bus
--   M_ABus                 -- Master address bus
--   M_wrDBus               -- Master write data bus
--   M_wrBurst              -- Master burst write transfer indicator
--   M_rdBurst              -- Master burst read transfer indicator
--   PLB_MAddrAck           -- PLB reply to master for address acknowledge
--   PLB_MSSize             -- PLB reply to master for slave data bus size
--   PLB_MRearbitrate       -- PLB reply to master for bus re-arbitrate
--                             indicator
--   PLB_MTimeout           -- PLB reply to master for bus time out indicator
--   PLB_MBusy              -- PLB reply to master for slave busy indicator
--   PLB_MRdErr             -- PLB reply to master for slave read error 
--                             indicator
--   PLB_MWrErr             -- PLB reply to master for slave write error 
--                             indicator
--   PLB_MIRQ               -- PLB reply to master for slave interrupt 
--                             indicator
--   PLB_MRdDBus            -- PLB reply to master for read data bus
--   PLB_MRdWdAddr          -- PLB reply to master for read word address
--   PLB_MRdDAck            -- PLB reply to master for read data acknowledge
--   PLB_MRdBTerm           -- PLB reply to master for terminate read burst 
--                             indicator
--   PLB_MWrDAck            -- PLB reply to master for write data acknowledge
--   PLB_MWrBTerm           -- PLB reply to master for terminate write burst 
--                             indicator
--
-- -- PLB Slave Interface signals
------------------------------------
--   PLB_ABus               -- PLB address bus
--   PLB_UABus              -- PLB upper address bus
--   PLB_PAValid            -- PLB primary address valid indicator
--   PLB_SAValid            -- PLB secondary address valid indicator
--   PLB_rdPrim             -- PLB secondary to primary read request indicator
--   PLB_wrPrim             -- PLB secondary to primary write request indicator
--   PLB_masterID           -- PLB current master identifier
--   PLB_abort              -- PLB abort request indicator
--   PLB_busLock            -- PLB bus lock
--   PLB_RNW                -- PLB read/not write
--   PLB_BE                 -- PLB byte enables
--   PLB_MSize              -- PLB master data bus size
--   PLB_size               -- PLB transfer size
--   PLB_type               -- PLB transfer type
--   PLB_lockErr            -- PLB lock error indicator
--   PLB_wrDBus             -- PLB write data bus
--   PLB_wrBurst            -- PLB burst write transfer indicator
--   PLB_rdBurst            -- PLB burst read transfer indicator
--   PLB_wrPendReq          -- PLB write pending bus request indicator
--   PLB_rdPendReq          -- PLB read pending bus request indicator
--   PLB_wrPendPri          -- PLB write pending request priority
--   PLB_rdPendPri          -- PLB read pending request priority
--   PLB_reqPri             -- PLB current request priority
--   PLB_TAttribute         -- PLB transfer attribute
--   Sl_addrAck             -- Slave address acknowledge
--   Sl_SSize               -- Slave data bus size
--   Sl_wait                -- Slave wait indicator
--   Sl_rearbitrate         -- Slave re-arbitrate bus indicator
--   Sl_wrDAck              -- Slave write data acknowledge
--   Sl_wrComp              -- Slave write transfer complete indicator
--   Sl_wrBTerm             -- Slave terminate write burst transfer
--   Sl_rdDBus              -- Slave read data bus
--   Sl_rdWdAddr            -- Slave read word address
--   Sl_rdDAck              -- Slave read data acknowledge
--   Sl_rdComp              -- Slave read transfer complete indicator
--   Sl_rdBTerm             -- Slave terminate read burst transfer
--   Sl_MBusy               -- Slave busy indicator
--   Sl_MWrErr              -- Slave write error indicator
--   Sl_MRdErr              -- Slave read error indicator
--   Sl_MIRQ                -- Slave interrupt indicator
--
-- -- DCR Slave Interface signals
------------------------------------
--   DCR_Clk                -- DCR clock
--   DCR_Rst                -- DCR reset
--   DCR_Read               -- Read request from DCR master
--   DCR_Write              -- Write request from DCR master
--   DCR_ABus               -- DCR Slave Address Bus
--   DCR_Sl_DBus            -- Data bus to DCR Slave
--   Sl_DCRDBus             -- DCR Slave response for a read transaction
--   Sl_DCRAck              -- DCR Slave response for read or write transaction
--
-- TFT Interface Signals
------------------------------------
--   SYS_TFT_Clk            -- TFT input clock
--
-- -- TFT Common Interface Signals
------------------------------------
--   TFT_HSYNC              -- TFT Hsync 
--   TFT_VSYNC              -- TFT Vsync 
--   TFT_DE                 -- TFT Data enable
--   TFT_DPS                -- TFT display scan pin  
--
-- -- TFT VGA Interface Signals
------------------------------------
--   TFT_VGA_CLK            -- TFT VGA clock output
--   TFT_VGA_R              -- TFT VGA Red pixel data
--   TFT_VGA_G              -- TFT VGA Green pixel data
--   TFT_VGA_B              -- TFT VGA Blue pixel data
--
-- -- TFT DVI Interface Signals
------------------------------------
--   TFT_DVI_CLK_P          -- TFT DVI differntial clock P output
--   TFT_DVI_CLK_N          -- TFT DVI differntial clock N output
--   TFT_DVI_DATA           -- TFT DVI RGB pixel data
--
-- -- Chrontel I2C Interface Signals
------------------------------------
--   TFT_IIC_SCL_I          -- I2C clock input
--   TFT_IIC_SCL_O          -- I2C clock output
--   TFT_IIC_SCL_T          -- I2C clock tristate cntrol
--   TFT_IIC_SDA_I          -- I2C data input
--   TFT_IIC_SDA_O          -- I2C data output
--   TFT_IIC_SDA_T          -- I2C data tristate cntrol
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity xps_tft is
  generic
  (

    C_FAMILY                : string                    := "virtex5";
    ------------------------------------------------------------------
    -- TFT Controller generics
    C_DCR_SPLB_SLAVE_IF     : integer range 0 to 1      := 1; -- (0:DCR, 1:PLB)
    C_TFT_INTERFACE         : integer range 0 to 1      := 1; -- (0:VGA, 1:DVI)
    C_I2C_SLAVE_ADDR        : std_logic_vector          := "1110110";
    C_DEFAULT_TFT_BASE_ADDR : std_logic_vector          := X"F0000000";
    ------------------------------------------------------------------
    -- DCR Interface generics
    C_DCR_BASEADDR          : std_logic_vector          := "1111111111";
    C_DCR_HIGHADDR          : std_logic_vector          := "0000000000";
    ------------------------------------------------------------------
    -- PLBv46 Master Burst Interface  generics
    C_MPLB_AWIDTH           : integer range 32 to 32    := 32;
    C_MPLB_DWIDTH           : integer range 64 to 128   := 64;
    C_MPLB_NATIVE_DWIDTH    : integer range 64 to 64    := 64;
    C_MPLB_SMALLEST_SLAVE   : integer range 32 to 128   := 32;
    ------------------------------------------------------------------
    -- PLBv46 Slave Single Interface generics
    C_SPLB_AWIDTH           : integer range 32 to 32    := 32;
    C_SPLB_DWIDTH           : integer range 32 to 128   := 32;
    C_SPLB_P2P              : integer range 0 to 0      := 0;
    C_SPLB_MID_WIDTH        : integer range 0 to 4      := 1;
    C_SPLB_NUM_MASTERS      : integer range 1 to 16     := 1;
    C_SPLB_NATIVE_DWIDTH    : integer range 32 to 32    := 32;
    C_SPLB_BASEADDR         : std_logic_vector          := X"FFFFFFFF";
    C_SPLB_HIGHADDR         : std_logic_vector          := X"00000000"
    ------------------------------------------------------------------
  );
 port
  (
       -------------------
    -- SYSTEM INTERFACE SIGNALS
       -------------------
    SPLB_Clk                : in  std_logic;
    SPLB_Rst                : in  std_logic;
    MPLB_Clk                : in  std_logic;
    MPLB_Rst                : in  std_logic;
    MD_error                : out std_logic;
     
       ------------------------------------------
    -- MASTER REQUEST/QUALIFIERS TO PLB (OUTPUTS)
       ------------------------------------------
    M_request               : out std_logic;
    M_priority              : out std_logic_vector(0 to 1);
    M_busLock               : out std_logic;
    M_RNW                   : out std_logic;
    M_BE                    : out std_logic_vector(0 to C_MPLB_DWIDTH/8-1);
    M_MSize                 : out std_logic_vector(0 to 1);
    M_size                  : out std_logic_vector(0 to 3);
    M_type                  : out std_logic_vector(0 to 2);
    M_ABus                  : out std_logic_vector(0 to 31);
    M_wrBurst               : out std_logic;
    M_rdBurst               : out std_logic;
    M_wrDBus                : out std_logic_vector(0 to C_MPLB_DWIDTH-1);
       ----------------------------
    -- PLB REPLY SIGNALS TO IP (INPUTS)
       ----------------------------
    PLB_MSSize              : in  std_logic_vector(0 to 1);
    PLB_MAddrAck            : in  std_logic;
    PLB_MRearbitrate        : in  std_logic;
    PLB_MTimeout            : in  std_logic;
    PLB_MRdErr              : in  std_logic;
    PLB_MWrErr              : in  std_logic;
    PLB_MRdDBus             : in  std_logic_vector(0 to (C_MPLB_DWIDTH-1));
    PLB_MRdDAck             : in  std_logic;
    PLB_MWrDAck             : in  std_logic;
    PLB_MRdBTerm            : in  std_logic;
    PLB_MWrBTerm            : in  std_logic;
        -------------------------
     -- UNUSED PLB MASTER SIGNALS
        -------------------------
    M_TAttribute            : out std_logic_vector(0 to 15);
    M_lockErr               : out std_logic;
    M_abort                 : out std_logic;
    M_UABus                 : out std_logic_vector(0 to 31);
    PLB_MBusy               : in  std_logic;
    PLB_MIRQ                : in  std_logic;
    PLB_MRdWdAddr           : in  std_logic_vector(0 to 3);
       --------------------------------------
    -- PLB REQUEST/QUALIFIERS TO IP (INPUTS)
       --------------------------------------
    PLB_ABus                : in  std_logic_vector(0 to 31);
    PLB_PAValid             : in  std_logic;
    PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
    PLB_RNW                 : in  std_logic;
    PLB_BE                  : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
    PLB_size                : in  std_logic_vector(0 to 3);
    PLB_type                : in  std_logic_vector(0 to 2);
    PLB_wrDBus              : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);

       -----------------------------
    -- SLAVE REPLY TO PLB (OUTPUTS)
       -----------------------------
    Sl_addrAck              : out std_logic;
    Sl_SSize                : out std_logic_vector(0 to 1);
    Sl_wait                 : out std_logic;
    Sl_rearbitrate          : out std_logic;
    Sl_wrDAck               : out std_logic;
    Sl_wrComp               : out std_logic;
    Sl_rdDBus               : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
    Sl_rdDAck               : out std_logic;
    Sl_rdComp               : out std_logic;
    Sl_MBusy                : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MWrErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
    Sl_MRdErr               : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

       -------------------------
    -- UNUSED PLB SLAVE SIGNALS
       -------------------------
    PLB_UABus               : in  std_logic_vector(0 to 31);
    PLB_SAValid             : in  std_logic;
    PLB_rdPrim              : in  std_logic;
    PLB_wrPrim              : in  std_logic;
    PLB_abort               : in  std_logic;
    PLB_busLock             : in  std_logic;
    PLB_MSize               : in  std_logic_vector(0 to 1);
    PLB_lockErr             : in  std_logic;
    PLB_wrBurst             : in  std_logic;
    PLB_rdBurst             : in  std_logic;
    PLB_wrPendReq           : in  std_logic;
    PLB_rdPendReq           : in  std_logic;
    PLB_wrPendPri           : in  std_logic_vector(0 to 1);
    PLB_rdPendPri           : in  std_logic_vector(0 to 1);
    PLB_reqPri              : in  std_logic_vector(0 to 1);
    PLB_TAttribute          : in  std_logic_vector(0 to 15);
    Sl_wrBTerm              : out std_logic;
    Sl_rdWdAddr             : out std_logic_vector(0 to 3);
    Sl_rdBTerm              : out std_logic;
    Sl_MIRQ                 : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

       -----------------------------
    -- DCR REQUEST/QUALIFIERS TO IP 
       -----------------------------
    DCR_Clk                 : in  std_logic;
    DCR_Rst                 : in  std_logic;
    DCR_Read                : in  std_logic;
    DCR_Write               : in  std_logic;
    DCR_ABus                : in  std_logic_vector(0 to 9);
    DCR_Sl_DBus             : in  std_logic_vector(0 to 31);
        ---------------------------
     -- DCR SLAVE RESPONSE SIGNALS
        ---------------------------
    Sl_DCRDBus              : out std_logic_vector(0 to 31);
    Sl_DCRAck               : out std_logic;


       ----------------------
    -- TFT INTERFACE SIGNALS
       ----------------------
    SYS_TFT_Clk             : in  std_logic;

    -- TFT Common Interface Signals
    TFT_HSYNC               : out  std_logic;
    TFT_VSYNC               : out  std_logic;
    TFT_DE                  : out  std_logic;
    TFT_DPS                 : out  std_logic;
    
    -- TFT VGA Interface Ports
    TFT_VGA_CLK             : out std_logic;
    TFT_VGA_R               : out std_logic_vector(5 downto 0);
    TFT_VGA_G               : out std_logic_vector(5 downto 0);
    TFT_VGA_B               : out std_logic_vector(5 downto 0);

    -- TFT DVI Interface Ports     
    TFT_DVI_CLK_P           : out  std_logic;
    TFT_DVI_CLK_N           : out  std_logic;
    TFT_DVI_DATA            : out  std_logic_vector(11 downto 0);

       -------------------------------------------
    -- I2C INTERFACE SIGNALS FOR CHRONTEL CH7301C
    -- DVI TRANSMITTER CHIP
       -------------------------------------------
    TFT_IIC_SCL_I           : in  std_logic;    
    TFT_IIC_SCL_O           : out std_logic;
    TFT_IIC_SCL_T           : out std_logic;
    TFT_IIC_SDA_I           : in  std_logic;
    TFT_IIC_SDA_O           : out std_logic;
    TFT_IIC_SDA_T           : out std_logic
  );

-------------------------------------------------------------------------------
-- PSFUTIL Attributes
-------------------------------------------------------------------------------
    ATTRIBUTE SIGIS          : string;
    ATTRIBUTE MAX_FANOUT     : string;

    ATTRIBUTE SIGIS       of SPLB_Clk    : signal is "CLK";
    ATTRIBUTE SIGIS       of MPLB_Clk    : signal is "CLK";
    ATTRIBUTE SIGIS       of SPLB_Rst    : signal is "RST";
    ATTRIBUTE SIGIS       of MPLB_Rst    : signal is "RST";
    ATTRIBUTE SIGIS       of DCR_Clk     : signal is "CLK";
    ATTRIBUTE SIGIS       of DCR_Rst     : signal is "RST";
    ATTRIBUTE SIGIS       of SYS_TFT_Clk : signal is "CLK";

    ATTRIBUTE MAX_FANOUT  of SPLB_Clk    : signal is "10000";
    ATTRIBUTE MAX_FANOUT  of SPLB_Rst    : signal is "10000";
    ATTRIBUTE MAX_FANOUT  of MPLB_Clk    : signal is "10000";
    ATTRIBUTE MAX_FANOUT  of MPLB_Rst    : signal is "10000";

end entity xps_tft;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of xps_tft is

  ------------------------------------------
  -- Array of base/high address pairs for each address range
  ------------------------------------------
  constant ZERO_ADDR_PAD : std_logic_vector(0 to 31) := (others => '0');
  constant USER_BASEADDR : std_logic_vector  := C_SPLB_BASEADDR or X"00000000";
  constant USER_HIGHADDR : std_logic_vector  := C_SPLB_BASEADDR or X"0000000F";

  constant IPIF_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE  := 
    (
      ZERO_ADDR_PAD & USER_BASEADDR,  -- user logic space base address
      ZERO_ADDR_PAD & USER_HIGHADDR   -- user logic space high address
    );

  ------------------------------------------
  -- Array of desired number of chip enables for each address range
  ------------------------------------------
  constant USER_MST_NUM_REG        : integer            := 4;
  constant USER_NUM_REG            : integer            := USER_MST_NUM_REG;
  constant IPIF_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE := 
    (
      0  => 4  -- number of ce for user logic master space
    );


  ------------------------------------------
  -- Inhibit the automatic inculsion of the Conversion Cycle and Burst Length 
  -- Expansion logic
  -- 0 = allow automatic inclusion of the CC and BLE logic
  -- 1 = inhibit automatic inclusion of the CC and BLE logic
  ------------------------------------------
  constant IPIF_INHIBIT_CC_BLE_INCLUSION  : integer     := 0;

  ------------------------------------------
  -- Width of the master address bus (32 only)
  ------------------------------------------
  constant USER_MST_AWIDTH         : integer := C_MPLB_AWIDTH;

  ------------------------------------------
  -- TFT Base Address, I2C Slave Address,
  -- DCR base address
  -- Converting std_logic_vector to Integer
  ------------------------------------------
  constant DEFAULT_TFT_BASE_ADDR : std_logic_vector(0 to 10) 
                                   := C_DEFAULT_TFT_BASE_ADDR(0 to 10);
  constant TFT_BASE_ADDR         : integer 
                                   := CONV_INTEGER(DEFAULT_TFT_BASE_ADDR);
  
  constant I2C_SLAVE_ADDR        : integer := CONV_INTEGER(C_I2C_SLAVE_ADDR);
  constant DCR_BASEADDR          : integer := CONV_INTEGER(C_DCR_BASEADDR);
  constant DCR_HIGHADDR          : integer := CONV_INTEGER(C_DCR_HIGHADDR);
  
  -- Added for generating IO styles
  constant V2P_IO                : boolean := supported(C_FAMILY, (u_FDDRRSE));
  constant S3E_IO                : boolean := supported(C_FAMILY, (u_ODDR2));
  constant V4_IO                 : boolean := supported(C_FAMILY, (u_ODDR));
  
  -----------------------------------------------------------------------------
  -- Function: get_io_reg_style
  -- Purpose: Get array size for ARD_ID_ARRAY, ARD_DWIDTH_ARRAY, and 
  --          ARD_NUM_CE_ARRAY
  -----------------------------------------------------------------------------
  function get_io_reg_style return integer is
  variable io_reg_style : integer;
  begin

      io_reg_style := 0;
  
      if (V4_IO = TRUE) then 
         io_reg_style := 0;
      elsif (S3E_IO = TRUE) then 
         io_reg_style := 1;      
      elsif (V2P_IO = TRUE) then 
         io_reg_style := 2;
      else   
         io_reg_style := 0;         
      end if;
    
      return io_reg_style;
      
  end function get_io_reg_style;
  
  constant  IO_REG_STYLE : integer := get_io_reg_style;
   
  ------------------------------------------
  -- Signal Declaration 
  ------------------------------------------

  signal bus2ip_clk   : std_logic;
  signal bus2ip_reset : std_logic;
  signal ip2bus_data  : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH - 1):=
                        (others  => '0');
  signal ip2bus_error : std_logic;
  signal ip2bus_wrack : std_logic;
  signal ip2bus_rdack : std_logic;
  signal bus2ip_data  : std_logic_vector
                        (0 to C_SPLB_NATIVE_DWIDTH - 1);
  signal bus2ip_rdce  : std_logic_vector
                        (0 to calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
  signal bus2ip_wrce  : std_logic_vector
                        (0 to calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1);
  signal bus2ip_be    : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
  
  signal ip2bus_mstrd_req          : std_logic;
  signal ip2bus_mst_addr           : std_logic_vector(0 to C_MPLB_AWIDTH-1);
  signal ip2bus_mst_length         : std_logic_vector(0 to 11);
  signal ip2bus_mst_be             : std_logic_vector
                                     (0 to C_MPLB_NATIVE_DWIDTH/8-1);
  signal ip2bus_mst_type           : std_logic;
  signal ip2bus_mst_lock           : std_logic;
  signal ip2bus_mst_reset          : std_logic;
  signal bus2ip_mst_cmdack         : std_logic;
  signal bus2ip_mst_cmplt          : std_logic;
  signal bus2ip_mstrd_d            : std_logic_vector
                                      (0 to C_MPLB_NATIVE_DWIDTH-1);
  signal bus2ip_mstrd_eof_n        : std_logic;
  signal bus2ip_mstrd_src_rdy_n    : std_logic;
  signal ip2bus_mstrd_dst_rdy_n    : std_logic;
  signal ip2bus_mstrd_dst_dsc_n    : std_logic;
  signal ip2bus_mstwr_d            : std_logic_vector
                                      (0 to C_MPLB_NATIVE_DWIDTH-1)
                                       := (others => '0');
  signal ip2bus_mstwr_rem          : std_logic_vector
                                      (0 to C_MPLB_NATIVE_DWIDTH/8-1)
                                       := (others => '0');
  
  ------------------------------------------
  -- Component declaration for verilog user logic
  ------------------------------------------
  component tft_controller is
    generic
    (
      -- TFT Controller parameters
      C_DCR_SPLB_SLAVE_IF     : integer  := 1;
      C_TFT_INTERFACE         : integer  := 1;
      C_I2C_SLAVE_ADDR        : integer;
      C_DEFAULT_TFT_BASE_ADDR : integer;
      C_DCR_BASEADDR          : integer;
      C_DCR_HIGHADDR          : integer;
      C_IOREG_STYLE           : integer  := 1; 
       -- Bus protocol parameters
      C_FAMILY                : string   := "virtex5";
      C_SLV_DWIDTH            : integer  := 32;
      C_MST_AWIDTH            : integer  := 32;
      C_MST_DWIDTH            : integer  := 32;
      C_NUM_REG               : integer  := 4
      -------------------------------------------------------
    );
    port
    (
      -- DCR Interface Ports
      DCR_Clk                    : in  std_logic;
      DCR_Rst                    : in  std_logic;
      DCR_Read                   : in  std_logic;
      DCR_Write                  : in  std_logic;
      DCR_ABus                   : in  std_logic_vector(0 to 9);
      DCR_Sl_DBus                : in  std_logic_vector(0 to 31);
      Sl_DCRDBus                 : out std_logic_vector(0 to 31);
      Sl_DCRAck                  : out std_logic;
      
      -- TFT Interface Ports
      SYS_TFT_Clk                : in  std_logic;
      -- TFT Common Interface Ports
      TFT_HSYNC                  : out std_logic;
      TFT_VSYNC                  : out std_logic;
      TFT_DE                     : out std_logic;
      TFT_DPS                    : out std_logic;

      -- VGA Interface Ports
      TFT_VGA_CLK                : out std_logic;
      TFT_VGA_R                  : out std_logic_vector(5 downto 0);
      TFT_VGA_G                  : out std_logic_vector(5 downto 0);
      TFT_VGA_B                  : out std_logic_vector(5 downto 0);

      -- DVI Interface Ports     
      TFT_DVI_CLK_P              : out std_logic;
      TFT_DVI_CLK_N              : out std_logic;
      TFT_DVI_DATA               : out std_logic_vector(11 downto 0);

      -- I2C interface for Chrontel Chip
      TFT_IIC_SCL_I              : in  std_logic;    
      TFT_IIC_SCL_O              : out std_logic;
      TFT_IIC_SCL_T              : out std_logic;
      TFT_IIC_SDA_I              : in  std_logic;
      TFT_IIC_SDA_O              : out std_logic;
      TFT_IIC_SDA_T              : out std_logic;

      -- Bus protocol ports
      SPLB_Clk                   : in  std_logic;
      SPLB_Rst                   : in  std_logic;
      Bus2IP_Data                : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
      Bus2IP_RdCE                : in  std_logic_vector(0 to C_NUM_REG-1);
      Bus2IP_WrCE                : in  std_logic_vector(0 to C_NUM_REG-1);
      Bus2IP_BE                  : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
      IP2Bus_Data                : out std_logic_vector(0 to C_SLV_DWIDTH-1);
      IP2Bus_RdAck               : out std_logic;
      IP2Bus_WrAck               : out std_logic;
      IP2Bus_Error               : out std_logic;
      
      MPLB_Clk                   : in  std_logic;
      MPLB_Rst                   : in  std_logic;
      IP2Bus_MstRd_Req           : out std_logic;
      IP2Bus_Mst_Addr            : out std_logic_vector(0 to C_MST_AWIDTH-1);
      IP2Bus_Mst_BE              : out std_logic_vector(0 to C_MST_DWIDTH/8-1);
      IP2Bus_Mst_Length          : out std_logic_vector(0 to 11);
      IP2Bus_Mst_Type            : out std_logic;
      IP2Bus_Mst_Lock            : out std_logic;
      IP2Bus_Mst_Reset           : out std_logic;
      Bus2IP_Mst_CmdAck          : in  std_logic;
      Bus2IP_Mst_Cmplt           : in  std_logic;
      Bus2IP_MstRd_d             : in  std_logic_vector(0 to C_MST_DWIDTH-1);
      Bus2IP_MstRd_eof_n         : in  std_logic;
      Bus2IP_MstRd_src_rdy_n     : in  std_logic;
      IP2Bus_MstRd_dst_rdy_n     : out std_logic;
      IP2Bus_MstRd_dst_dsc_n     : out std_logic
    );
  end component tft_controller;

begin

  -----------------------------------------------------------------------------
  -- Instantiate PLBv46 slave interface based on generic C_DCR_SPLB_SLAVE_IF.
  -- Includes PLB Slave interface to provide TFT Register access through PLB
  -----------------------------------------------------------------------------
  INCLUDE_PLB_IPIF_GEN: if C_DCR_SPLB_SLAVE_IF=1 generate

  ------------------------------------------
  -- instantiate plbv46_slave_single
  ------------------------------------------
  PLBV46_SLAVE_SINGLE_I: entity plbv46_slave_single_v1_01_a.plbv46_slave_single
    generic map
    (
      C_ARD_ADDR_RANGE_ARRAY     => IPIF_ARD_ADDR_RANGE_ARRAY ,
      C_ARD_NUM_CE_ARRAY         => IPIF_ARD_NUM_CE_ARRAY     ,
      C_SPLB_P2P                 => C_SPLB_P2P                ,
      C_SPLB_MID_WIDTH           => C_SPLB_MID_WIDTH          ,
      C_SPLB_NUM_MASTERS         => C_SPLB_NUM_MASTERS        ,
      C_SPLB_AWIDTH              => C_SPLB_AWIDTH             ,
      C_SPLB_DWIDTH              => C_SPLB_DWIDTH             ,
      C_SIPIF_DWIDTH             => C_SPLB_NATIVE_DWIDTH      ,
      C_FAMILY                   => C_FAMILY
    )
    port map
    (
      SPLB_Clk                   => SPLB_Clk                  ,
      SPLB_Rst                   => SPLB_Rst                  ,
      PLB_ABus                   => PLB_ABus                  ,
      PLB_UABus                  => PLB_UABus                 ,
      PLB_PAValid                => PLB_PAValid               ,
      PLB_SAValid                => PLB_SAValid               ,
      PLB_rdPrim                 => PLB_rdPrim                ,
      PLB_wrPrim                 => PLB_wrPrim                ,
      PLB_masterID               => PLB_masterID              ,
      PLB_abort                  => PLB_abort                 ,
      PLB_busLock                => PLB_busLock               ,
      PLB_RNW                    => PLB_RNW                   ,
      PLB_BE                     => PLB_BE                    ,
      PLB_MSize                  => PLB_MSize                 ,
      PLB_size                   => PLB_size                  ,
      PLB_type                   => PLB_type                  ,
      PLB_lockErr                => PLB_lockErr               ,
      PLB_wrDBus                 => PLB_wrDBus                ,
      PLB_wrBurst                => PLB_wrBurst               ,
      PLB_rdBurst                => PLB_rdBurst               ,
      PLB_wrPendReq              => PLB_wrPendReq             ,
      PLB_rdPendReq              => PLB_rdPendReq             ,
      PLB_wrPendPri              => PLB_wrPendPri             ,
      PLB_rdPendPri              => PLB_rdPendPri             ,
      PLB_reqPri                 => PLB_reqPri                ,
      PLB_TAttribute             => PLB_TAttribute            ,
      Sl_addrAck                 => Sl_addrAck                ,
      Sl_SSize                   => Sl_SSize                  ,
      Sl_wait                    => Sl_wait                   ,
      Sl_rearbitrate             => Sl_rearbitrate            ,
      Sl_wrDAck                  => Sl_wrDAck                 ,
      Sl_wrComp                  => Sl_wrComp                 ,
      Sl_wrBTerm                 => Sl_wrBTerm                ,
      Sl_rdDBus                  => Sl_rdDBus                 ,
      Sl_rdWdAddr                => Sl_rdWdAddr               ,
      Sl_rdDAck                  => Sl_rdDAck                 ,
      Sl_rdComp                  => Sl_rdComp                 ,
      Sl_rdBTerm                 => Sl_rdBTerm                ,
      Sl_MBusy                   => Sl_MBusy                  ,
      Sl_MWrErr                  => Sl_MWrErr                 ,
      Sl_MRdErr                  => Sl_MRdErr                 ,
      Sl_MIRQ                    => Sl_MIRQ                   ,
      Bus2IP_Clk                 => bus2ip_clk                ,
      Bus2IP_Reset               => bus2ip_reset              ,
      IP2Bus_Data                => ip2bus_data               ,
      IP2Bus_WrAck               => ip2bus_wrack              ,
      IP2Bus_RdAck               => ip2bus_rdack              ,
      IP2Bus_Error               => ip2bus_error              ,
      Bus2IP_Addr                => open                      ,
      Bus2IP_Data                => bus2ip_data               ,
      Bus2IP_RNW                 => open                      ,
      Bus2IP_BE                  => bus2ip_be                 ,
      Bus2IP_CS                  => open                      ,
      Bus2IP_RdCE                => bus2ip_rdce               ,
      Bus2IP_WrCE                => bus2ip_wrce
    );

  end generate INCLUDE_PLB_IPIF_GEN;

  -----------------------------------------------------------------------------
  -- If PLB IPIF is not included in the design, drive '0' on all the plb slave
  -- output ports. 
  -----------------------------------------------------------------------------
  NO_INCLUDE_PLB_IPIF_GEN: if C_DCR_SPLB_SLAVE_IF=0 generate

     Sl_addrAck                  <= '0';
     Sl_SSize                    <= (others => '0');
     Sl_wait                     <= '0';
     Sl_rearbitrate              <= '0';
     Sl_wrDAck                   <= '0';
     Sl_wrComp                   <= '0';
     Sl_rdDBus                   <= (others => '0');
     Sl_rdDAck                   <= '0';
     Sl_rdComp                   <= '0';
     Sl_MBusy                    <= (others => '0');
     Sl_MWrErr                   <= (others => '0');
     Sl_MRdErr                   <= (others => '0'); 
     bus2ip_clk                  <= '0';
     bus2ip_reset                <= '0';
     bus2ip_data                 <= (others => '0');
     bus2ip_rdce                 <= (others => '0');
     bus2ip_wrce                 <= (others => '0'); 
     bus2ip_be                   <= (others => '0');
   
  end generate NO_INCLUDE_PLB_IPIF_GEN;

  -----------------------------------------------------------------------------
  -- Instantiate plbv46_master_burst
  -----------------------------------------------------------------------------
  PLBV46_MASTER_BURST_I : entity plbv46_master_burst_v1_01_a.plbv46_master_burst
    generic map
     (
      C_MPLB_AWIDTH              => C_MPLB_AWIDTH                  ,
      C_MPLB_DWIDTH              => C_MPLB_DWIDTH                  ,
      C_MPLB_NATIVE_DWIDTH       => C_MPLB_NATIVE_DWIDTH           ,
      C_MPLB_SMALLEST_SLAVE      => C_MPLB_SMALLEST_SLAVE          ,
      C_INHIBIT_CC_BLE_INCLUSION => IPIF_INHIBIT_CC_BLE_INCLUSION  ,
      C_FAMILY                   => C_FAMILY
      )
    port map
     (
      MPLB_Clk                   => MPLB_Clk                  ,
      MPLB_Rst                   => MPLB_Rst                  ,
      MD_error                   => MD_error                  ,
      M_request                  => M_request                 ,
      M_priority                 => M_priority                ,
      M_busLock                  => M_busLock                 ,
      M_RNW                      => M_RNW                     ,
      M_BE                       => M_BE                      ,
      M_MSize                    => M_MSize                   ,
      M_size                     => M_size                    ,
      M_type                     => M_type                    ,
      M_TAttribute               => M_TAttribute              ,
      M_lockErr                  => M_lockErr                 ,
      M_abort                    => M_abort                   ,
      M_UABus                    => M_UABus                   ,
      M_ABus                     => M_ABus                    ,
      M_wrDBus                   => M_wrDBus                  ,
      M_wrBurst                  => M_wrBurst                 ,
      M_rdBurst                  => M_rdBurst                 ,
      PLB_MAddrAck               => PLB_MAddrAck              ,
      PLB_MSSize                 => PLB_MSSize                ,
      PLB_MRearbitrate           => PLB_MRearbitrate          ,
      PLB_MTimeout               => PLB_MTimeout              ,
      PLB_MBusy                  => PLB_MBusy                 ,
      PLB_MRdErr                 => PLB_MRdErr                ,
      PLB_MWrErr                 => PLB_MWrErr                ,
      PLB_MIRQ                   => PLB_MIRQ                  ,
      PLB_MRdDBus                => PLB_MRdDBus               ,
      PLB_MRdWdAddr              => PLB_MRdWdAddr             ,
      PLB_MRdDAck                => PLB_MRdDAck               ,
      PLB_MRdBTerm               => PLB_MRdBTerm              ,
      PLB_MWrDAck                => PLB_MWrDAck               ,
      PLB_MWrBTerm               => PLB_MWrBTerm              ,
      IP2Bus_MstRd_Req           => ip2bus_mstrd_req          ,
      IP2Bus_MstWr_Req           => '0'                       ,
      IP2Bus_Mst_Addr            => ip2bus_mst_addr           ,
      IP2Bus_Mst_Length          => ip2bus_mst_length         ,
      IP2Bus_Mst_BE              => ip2bus_mst_be             ,  
      IP2Bus_Mst_Type            => ip2bus_mst_type           ,
      IP2Bus_Mst_Lock            => ip2bus_mst_lock           ,
      IP2Bus_Mst_Reset           => ip2bus_mst_reset          ,
      Bus2IP_Mst_CmdAck          => bus2ip_mst_cmdack         ,
      Bus2IP_Mst_Cmplt           => bus2ip_mst_cmplt          ,
      Bus2IP_Mst_Error           => open                      ,
      Bus2IP_Mst_Rearbitrate     => open                      ,
      Bus2IP_Mst_Cmd_Timeout     => open                      ,
      Bus2IP_MstRd_d             => bus2ip_mstrd_d            ,
      Bus2IP_MstRd_rem           => open                      ,
      Bus2IP_MstRd_sof_n         => open                      ,
      Bus2IP_MstRd_eof_n         => bus2ip_mstrd_eof_n        ,
      Bus2IP_MstRd_src_rdy_n     => bus2ip_mstrd_src_rdy_n    ,
      Bus2IP_MstRd_src_dsc_n     => open                      ,
      IP2Bus_MstRd_dst_rdy_n     => ip2bus_mstrd_dst_rdy_n    ,
      IP2Bus_MstRd_dst_dsc_n     => ip2bus_mstrd_dst_dsc_n    ,
      IP2Bus_MstWr_d             => ip2bus_mstwr_d            ,
      IP2Bus_MstWr_rem           => ip2bus_mstwr_rem          ,
      IP2Bus_MstWr_sof_n         => '0'                       ,
      IP2Bus_MstWr_eof_n         => '0'                       ,
      IP2Bus_MstWr_src_rdy_n     => '0'                       ,
      IP2Bus_MstWr_src_dsc_n     => '0'                       ,
      Bus2IP_MstWr_dst_rdy_n     => open                      ,
      Bus2IP_MstWr_dst_dsc_n     => open
    );


  -----------------------------------------------------------------------------
  -- Instantiate TFT Controller 
  -----------------------------------------------------------------------------
  TFT_CTRL_I: tft_controller
    generic map (
      C_DCR_SPLB_SLAVE_IF        => C_DCR_SPLB_SLAVE_IF       ,                             
      C_TFT_INTERFACE            => C_TFT_INTERFACE           ,                                        
      C_I2C_SLAVE_ADDR           => I2C_SLAVE_ADDR            ,
      C_DEFAULT_TFT_BASE_ADDR    => TFT_BASE_ADDR             ,  
      C_DCR_BASEADDR             => DCR_BASEADDR              ,                     
      C_DCR_HIGHADDR             => DCR_HIGHADDR              ,             
      C_FAMILY                   => C_FAMILY                  , 
      C_IOREG_STYLE              => IO_REG_STYLE              ,
      C_SLV_DWIDTH               => C_SPLB_NATIVE_DWIDTH      ,
      C_MST_AWIDTH               => USER_MST_AWIDTH           ,        
      C_MST_DWIDTH               => C_MPLB_NATIVE_DWIDTH      ,
      C_NUM_REG                  => USER_NUM_REG              
     )                                                        
                                                              
    port map                                                  
     (                                                        
      -- DCR BUS                                              
      DCR_Clk                    => DCR_Clk                   ,    
      DCR_Rst                    => DCR_Rst                   ,
      DCR_Read                   => DCR_Read                  ,      
      DCR_Write                  => DCR_Write                 ,     
      DCR_ABus                   => DCR_ABus                  ,      
      DCR_Sl_DBus                => DCR_Sl_DBus               ,    
      Sl_DCRDBus                 => Sl_DCRDBus                ,   
      Sl_DCRAck                  => Sl_DCRAck                 ,       
                                                              
      -- TFT SIGNALS OUT TO HW                                
      SYS_TFT_Clk                => SYS_TFT_Clk               ,    
      TFT_HSYNC                  => TFT_HSYNC                 , 
      TFT_VSYNC                  => TFT_VSYNC                 , 
      TFT_DE                     => TFT_DE                    ,    
      TFT_DPS                    => TFT_DPS                   ,   
      TFT_VGA_CLK                => TFT_VGA_CLK               , 
      TFT_VGA_R                  => TFT_VGA_R                 , 
      TFT_VGA_G                  => TFT_VGA_G                 ,   
      TFT_VGA_B                  => TFT_VGA_B                 ,   
      TFT_DVI_CLK_P              => TFT_DVI_CLK_P             , 
      TFT_DVI_CLK_N              => TFT_DVI_CLK_N             , 
      TFT_DVI_DATA               => TFT_DVI_DATA              ,  
                                                              
      -- IIC init state machine for Chrontel CH7301C          
      TFT_IIC_SCL_I              => TFT_IIC_SCL_I             ,
      TFT_IIC_SCL_O              => TFT_IIC_SCL_O             , 
      TFT_IIC_SCL_T              => TFT_IIC_SCL_T             ,
      TFT_IIC_SDA_I              => TFT_IIC_SDA_I             , 
      TFT_IIC_SDA_O              => TFT_IIC_SDA_O             , 
      TFT_IIC_SDA_T              => TFT_IIC_SDA_T             , 
                                                              
      -- PLB slave interface signals        
      SPLB_Clk                   => bus2ip_clk                ,
      SPLB_Rst                   => bus2ip_reset              ,
      Bus2IP_Data                => bus2ip_data               ,
      Bus2IP_RdCE                => bus2ip_rdce               ,
      Bus2IP_WrCE                => bus2ip_wrce               ,
      Bus2IP_BE                  => bus2ip_be                 ,
      IP2Bus_Data                => IP2Bus_Data               ,
      IP2Bus_RdAck               => IP2Bus_RdAck              ,
      IP2Bus_WrAck               => IP2Bus_WrAck              ,
      IP2Bus_Error               => IP2Bus_Error              ,

      -- PLB Master interface signals                         
      MPLB_Clk                   => MPLB_Clk                  ,
      MPLB_Rst                   => MPLB_Rst                  ,
      IP2Bus_MstRd_Req           => ip2bus_mstrd_req          ,
      IP2Bus_Mst_Addr            => ip2bus_mst_addr           ,
      IP2Bus_Mst_BE              => ip2bus_mst_be             ,
      IP2Bus_Mst_Length          => ip2bus_mst_length         ,
      IP2Bus_Mst_Type            => ip2bus_mst_type           ,
      IP2Bus_Mst_Lock            => ip2bus_mst_lock           ,
      IP2Bus_Mst_Reset           => ip2bus_mst_reset          ,
      Bus2IP_Mst_CmdAck          => bus2ip_mst_cmdack         ,
      Bus2IP_Mst_Cmplt           => bus2ip_mst_cmplt          ,
      Bus2IP_MstRd_d             => bus2ip_mstrd_d            ,
      Bus2IP_MstRd_eof_n         => bus2ip_mstrd_eof_n        ,
      Bus2IP_MstRd_src_rdy_n     => bus2ip_mstrd_src_rdy_n    ,
      IP2Bus_MstRd_dst_rdy_n     => ip2bus_mstrd_dst_rdy_n    ,
      IP2Bus_MstRd_dst_dsc_n     => ip2bus_mstrd_dst_dsc_n    
    );

end imp;
