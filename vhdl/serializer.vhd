--------------------------------------------------------------------------------
-- Module Name:    VRAM - behavioral
--
-- Author: Anthony Blake
-- 
-- Description: 8 to 1 Serializer
--              
-- 
-- 
-- Dependencies: 
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serializer is

  port (
    clk          : in  std_logic;
    din          : in  unsigned(7 downto 0);
    strobe       : in  std_logic;
    dout         : out std_logic
    );

end serializer;

architecture rtl of serializer is

  signal data_latch : unsigned(7 downto 0);

begin  -- rtl;

  dout <= data_latch(7);

  p_regs : process (clk)
  begin  -- process p_regs
  if clk'event and clk = '1' then  -- rising clock edge
      if strobe = '1' then
        data_latch <= din;
      else
        data_latch <= data_latch(6 downto 0) & '0';
      end if;
    end if;
  end process p_regs;

end rtl;
