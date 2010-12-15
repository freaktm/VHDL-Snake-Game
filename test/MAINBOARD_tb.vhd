-------------------------------------------------------------------------------
-- Title      : Testbench for design "MAINBOARD"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MAINBOARD_tb.vhd
-- Author     : Aaron Storey  <freaktm@freaktm>
-- Company    : 
-- Created    : 2010-12-15
-- Last update: 2010-12-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-12-15  1.0      freaktm Created
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

  -- component ports
  signal ext_clk_50  : std_logic;
  signal ext_reset   : std_logic;
  signal clks_locked : std_logic;
  signal red_out     : std_logic;
  signal green_out   : std_logic;
  signal blue_out    : std_logic;
  signal hs_out      : std_logic;
  signal vs_out      : std_logic;
  signal ps2d        : std_logic;
  signal ps2c        : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

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
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here

    wait 100 ns;
    ext_reset <= '1';
    wait 100 ns;
    ext_reset <= '0';
    wait 100 ns;
    for loop
      wait 200 ns;
      tick <= '1';
      wait 1 ns;
      tick <= '0';
    end loop;  -- loop

    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration MAINBOARD_tb_tb_cfg of MAINBOARD_tb is
  for tb
  end for;
end MAINBOARD_tb_tb_cfg;

-------------------------------------------------------------------------------
