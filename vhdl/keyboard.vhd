----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:10:55 07/16/2009 
-- Design Name: 
-- Module Name:    KeyboardController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity KeyboardController is
  port (KeyboardClock : in  std_logic;
        KeyboardData  : in  std_logic;
        Direction     : out unsigned(2 downto 0)
        );
end KeyboardController;

architecture Behavioral of KeyboardController is

  signal bitCount      : integer range 0 to 10        := 0;
  signal scancodeReady : std_logic                    := '0';
  signal scancode      : std_logic_vector(7 downto 0) := (others => '0');
  signal breakReceived : std_logic                    := '0';
  signal KDirection    : unsigned(2 downto 0)         := (others => '0');

  constant keyboardA     : std_logic_vector(7 downto 0) := X"1C";
  constant keyboardD     : std_logic_vector(7 downto 0) := X"23";
  constant keyboardS     : std_logic_vector(7 downto 0) := X"1B";
  constant keyboardW     : std_logic_vector(7 downto 0) := X"1D";
  constant keyboardSPACE : std_logic_vector(7 downto 0) := X"29";

begin

  Direction <= KDirection;

  scankeyboard : process(KeyboardClock)
  begin
    if falling_edge(KeyboardClock) then
      if bitCount = 0 and KeyboardData = '0' then  --keyboard wants to send data
        scancodeReady <= '0';
        bitCount      <= bitCount + 1;
      elsif bitCount > 0 and bitCount < 9 then  -- shift one bit into the scancode from the left
        scancode <= KeyboardData & scancode(7 downto 1);
        bitCount <= bitCount + 1;
      elsif bitCount = 9 then           -- parity bit
        bitCount <= bitCount + 1;
      elsif bitCount = 10 then          -- end of message
        scancodeReady <= '1';
        bitCount      <= 0;
      end if;
    end if;
  end process scankeyboard;

  processkeyboard : process(scancodeReady, scancode)
  begin
    if scancodeReady'event and scancodeReady = '1' then
      -- breakcode breaks the current scancode
      if breakReceived = '1' then
        breakReceived <= '0';

      elsif breakReceived = '0' then
        -- scancode processing
        if scancode = "11110000" then   -- mark break for next scancode
          breakReceived <= '1';
        end if;

        if scancode = keyboardW then
          KDirection <= "001";
        elsif scancode = keyboardD then
          KDirection <= "010";
        elsif scancode = keyboardS then
          KDirection <= "011";
        elsif scancode = keyboardA then
          KDirection <= "100";
        elsif scancode = keyboardSPACE then
          KDirection <= "101";
        else
          KDirection <= "000";
        end if;
      end if;
    end if;
  end process processkeyboard;
end Behavioral;

