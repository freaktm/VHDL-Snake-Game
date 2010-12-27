-------------------------------------------------------------------------------
-- Title      : Testbench for design "MAINBOARD"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MAINBOARD_tb.vhd
-- Author     : Aaron Storey  <freaktm@freaktm>
-- Company    : 
-- Created    : 2010-12-26
-- Last update: 2010-12-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-12-26  1.0      freaktm	Created
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


begin  -- tb

  -- component instantiation
  DUT: MAINBOARD
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

  -- waveform generation
  WaveGen_Proc: process
  begin
    ps2c <= '0';
    ps2d <= '0';
    
    wait for 500 ns;
    ext_reset <= '1';
    wait for 500 ns;
    ext_reset <= '0';

    
    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration MAINBOARD_tb_tb_cfg of MAINBOARD_tb is
  for tb
  end for;
end MAINBOARD_tb_tb_cfg;

-------------------------------------------------------------------------------
