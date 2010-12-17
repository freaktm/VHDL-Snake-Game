-------------------------------------------------------------------------------
-- Title      : Testbench for design "game_logic"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : game_logic_tb.vhd
-- Author     : CompSci temp account 2  <cs002@nui.cs.waikato.ac.nz>
-- Company    : 
-- Created    : 2010-12-17
-- Last update: 2010-12-17
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-12-17  1.0      cs002	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity game_logic_tb is

end game_logic_tb;

-------------------------------------------------------------------------------

architecture tb of game_logic_tb is

  component game_logic
    port (
      clk25         : in  std_logic;
      ext_reset     : in  std_logic;
      ram_WEA       : out std_logic;
      ram_EN        : out std_logic;
      ram_address_a : out unsigned(12 downto 0) := "0000000000000";
      ram_input_a   : out unsigned(11 downto 0) := "000000000000";
      ram_output_a  : in  unsigned(11 downto 0) := "000000000000";
      Direction     : in  unsigned(2 downto 0));
  end component;

  -- component ports
  signal clk25_i         : std_logic;
  signal ext_reset_i     : std_logic;
  signal ram_WEA_i       : std_logic;
  signal ram_EN_i        : std_logic;
  signal ram_address_a_i : unsigned(12 downto 0) := "0000000000000";
  signal ram_input_a_i   : unsigned(11 downto 0) := "000000000000";
  signal ram_output_a_i  : unsigned(11 downto 0) := "000000000000";
  signal Direction_i     : unsigned(2 downto 0);
  signal tick : std_logic;
  

  -- clock
  

begin  -- tb

  -- component instantiation
  DUT: game_logic
    port map (
      clk25         => clk25_i,
      ext_reset     => ext_reset_i,
      ram_WEA       => ram_WEA_i,
      ram_EN        => ram_EN_i,
      ram_address_a => ram_address_a_i,
      ram_input_a   => ram_input_a_i,
      ram_output_a  => ram_output_a_i,
      Direction     => Direction_i);

  -- clock generation
  clk25_i <= not clk25_i after 10 ns;
  tick <= not tick after 50 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    ext_reset_i <= '0';
    wait for 100 ns;
    ext_reset_i <= '1';
    wait for 100 ns;
    ext_reset_i <= '0';
    wait;
    

    
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration game_logic_tb_tb_cfg of game_logic_tb is
  for tb
  end for;
end game_logic_tb_tb_cfg;

-------------------------------------------------------------------------------
