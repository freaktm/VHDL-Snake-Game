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
        Direction     : out std_logic_vector(1 downto 0)
        );
end KeyboardController;

architecture Behavioral of KeyboardController is

  signal bitCount      : integer range 0 to 10 := 0;
  signal scancodeReady : std_logic              := '0';
  signal scancode      : std_logic_vector(7 downto 0);
  signal breakReceived : std_logic              := '0';

  constant keyboardA : std_logic_vector(7 downto 0) := "00011100";
  constant keyboardY : std_logic_vector(7 downto 0) := "00011010";
  constant keyboardK : std_logic_vector(7 downto 0) := "01000010";
  constant keyboardM : std_logic_vector(7 downto 0) := "00111010";

begin

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
--                              if scancode = keyboardA or scancode = keyboardY then
--                                      LeftPaddleDirection <= 0;
--                              elsif scancode = keyboardK or scancode = keyboardM then
--                                      RightPaddleDirection <= 0;
--                              end if;
      elsif breakReceived = '0' then
        -- scancode processing
        if scancode = "11110000" then   -- mark break for next scancode
          breakReceived <= '1';
        end if;

        if scancode = keyboardA then
          Direction <= "00";
        elsif scancode = keyboardY then
          Direction <= "01";
        elsif scancode = keyboardK then
          Direction <= "10";
        elsif scancode = keyboardM then
          Direction <= "11";
        end if;
      end if;
    end if;
  end process processkeyboard;
end Behavioral;

