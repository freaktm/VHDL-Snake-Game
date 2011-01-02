-------------------------------------------------------------------------------
-- Title      : Testbench for design "MAINBOARD"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MAINBOARD_tb.vhd
-- Author     : Aaron Storey  <freaktm@freaktm>
-- Company    : 
-- Created    : 2010-12-26
-- Last update: 2011-01-02
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-12-26  1.0      freaktm Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity MAINBOARD_tb is

end MAINBOARD_tb;

-------------------------------------------------------------------------------

architecture tb of MAINBOARD_tb is

  component MAINBOARD
    port (
      ext_clk_50  : in  std_logic;
      ext_reset   : in  std_logic;
      clks_locked : out std_logic;
      red_out     : out std_logic;
      green_out   : out std_logic;
      blue_out    : out std_logic;
      hs_out      : out std_logic;
      vs_out      : out std_logic;
      ps2d        : in  std_logic;
      ps2c        : in  std_logic);
  end component;

  component keyboard_stim_gen
    port (
      clk, reset_n      : in  std_logic;
      data_in           : in  std_logic_vector(7 downto 0);
      wr_en             : in  std_logic;
      ready             : out std_logic;
      data_out, clk_out : out std_logic);
  end component;

  -- component ports
  signal ext_clk_50  : std_logic := '1';
  signal ext_reset   : std_logic := '0';
  signal clks_locked : std_logic;
  signal red_out     : std_logic;
  signal green_out   : std_logic;
  signal blue_out    : std_logic;
  signal hs_out      : std_logic;
  signal vs_out      : std_logic;
  signal ps2d        : std_logic;
  signal ps2c        : std_logic;

  signal reset_n          : std_logic;
  signal keyboard_ready   : std_logic;
  signal keyboard_wr_en   : std_logic;
  signal keyboard_data_in : std_logic_vector(7 downto 0);

  alias clk : std_logic is ext_clk_50;
  
begin  -- tb

  keyboard_stim_gen_1 : keyboard_stim_gen
    port map (
      clk      => clk,
      reset_n  => reset_n,
      data_in  => keyboard_data_in,
      wr_en    => keyboard_wr_en,
      ready    => keyboard_ready,
      data_out => ps2d,
      clk_out  => ps2c)
;

  -- component instantiation
  DUT : MAINBOARD
    port map (
      ext_clk_50  => ext_clk_50,
      ext_reset   => ext_reset,
      clks_locked => clks_locked,
      red_out     => red_out,
      green_out   => green_out,
      blue_out    => blue_out,
      hs_out      => hs_out,
      vs_out      => vs_out,
      ps2d        => ps2d,
      ps2c        => ps2c);

  -- clock generation
  ext_clk_50 <= not ext_clk_50 after 10 ns;

  reset_n <= not ext_reset;


  -- waveform generation
  WaveGen_Proc : process
  begin
    keyboard_wr_en   <= '0';
    keyboard_data_in <= X"00";

    wait for 500 ns;
    ext_reset <= '1';
    wait for 500 ns;
    ext_reset <= '0';

    wait for 10000 ns;

    --simulate left keyboard press
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"1C";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';

    wait until keyboard_ready = '1';
    wait for 1000 ns;

    --simulate keyboard break (release key)
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"F0";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';



    wait for 5000 ns;

    --simulate down keyboard press
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"1B";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';

    wait until keyboard_ready = '1';
    wait for 1000 ns;

    --simulate keyboard break (release key)
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"F0";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';



        wait for 5000 ns;

    --simulate right keyboard press
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"23";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';

    wait until keyboard_ready = '1';
    wait for 1000 ns;

    --simulate keyboard break (release key)
    wait until clk'event and clk = '1';
    keyboard_data_in <= X"F0";
    keyboard_wr_en   <= '1';
    wait until clk'event and clk = '1';
    keyboard_wr_en   <= '0';

    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration MAINBOARD_tb_tb_cfg of MAINBOARD_tb is
  for tb
  end for;
end MAINBOARD_tb_tb_cfg;

-------------------------------------------------------------------------------
