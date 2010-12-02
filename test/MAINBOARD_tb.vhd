-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity MAINBOARD_tb is

end MAINBOARD_tb;

-------------------------------------------------------------------------------

architecture synth of MAINBOARD_tb is

  component MAINBOARD
    port (
      ext_clk_50  : in  std_logic;
      ext_reset   : in  std_logic;
      clks_locked : out std_logic;
      red_out     : out std_logic;
      green_out   : out std_logic;
      blue_out    : out std_logic;
      hs_out      : out std_logic;
      vs_out      : out std_logic);
  end component;

  signal ext_clk_50_i  : std_logic;
  signal ext_reset_i   : std_logic;
  signal clks_locked_i : std_logic;
  signal red_out_i     : std_logic;
  signal green_out_i   : std_logic;
  signal blue_out_i    : std_logic;
  signal hs_out_i      : std_logic;
  signal vs_out_i      : std_logic;

begin  -- synth

  DUT: MAINBOARD
    port map (
        ext_clk_50  => ext_clk_50_i,
        ext_reset   => ext_reset_i,
        clks_locked => clks_locked_i,
        red_out     => red_out_i,
        green_out   => green_out_i,
        blue_out    => blue_out_i,
        hs_out      => hs_out_i,
        vs_out      => vs_out_i);

  

end synth;

-------------------------------------------------------------------------------
