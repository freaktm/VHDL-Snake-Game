--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
  port( 
		 clk25 : in std_logic;
       ext_reset   : in  std_logic;
       WEA_int     : out std_logic;
       EN_int      : out std_logic;
       address_a_int : out unsigned(12 downto 0):= "0000000000000";
	    input_a_int   : out unsigned(15 downto 0):= "0000000000000000";
       output_a_int   : in unsigned(15 downto 0) := "0000000000000000";
		 colour : out unsigned(1 downto 0);
		 Direction : in unsigned(2 downto 0)
		 );
end game_logic;

architecture Behavioral of game_logic is


signal head_cell : unsigned(12 downto 0) := to_unsigned(2440, 13); -- cell 2440
signal tail_cell : unsigned(12 downto 0) := to_unsigned(2520, 13); -- cell 2520 (cell below head cell)
signal next_head_cell : unsigned(12 downto 0) := to_unsigned(2360, 13);  -- cell 2360
signal next_tail_cell : unsigned(12 downto 0) := to_unsigned(2440, 13);  -- cell 2360
signal speed : unsigned(4 downto 0) := "11111"; -- slowest speed
signal score : unsigned(13 downto 0);
signal color : unsigned (1 downto 0);
signal current_direction : unsigned(2 downto 0);
signal skill : unsigned(4 downto 0) := "00000"; -- skill 0
signal WE_head : std_logic;
signal WE_tail : std_logic;
signal next_direction : unsigned(2 downto 0);
signal body_character : unsigned(12 downto 0) := to_unsigned(3*8, 13);
signal write_data_head : unsigned(15 downto 0); 
signal write_data_tail : unsigned(15 downto 0);
signal write_enable : std_logic;
                                      
begin




EN_int <= '1';
colour <= color;
WEA_int <= write_enable;

 



 p_movesnake : process (clk25, ext_reset, Direction)
 variable cnt: integer;
  begin
         if ext_reset = '1' then               -- asynchronous reset (active low)
        current_direction <= "001";
	   head_cell <= to_unsigned(2440, head_cell'length);
		tail_cell <= to_unsigned(2440, tail_cell'length);
		speed <= "11111";  -- slowest speed
		skill <= (others => '0'); -- lowest skill
		body_character <= to_unsigned(3*8, 13); -- vertical
		next_direction <= "001";
    elsif clk25'event and clk25 = '1' then    -- rising clock edge
	 
			if (write_enable = '1') then
				write_enable <= '0';
			end if;
		-- update next direction based on any keyboard input
			if (Direction = "000") then
			 next_direction <= next_direction;
			else
			 next_direction <= Direction;
				end if;
			--	 end of direction update
				
				-- move snake head every 0.5 seconds.
			cnt := cnt + 1;
		if cnt = 7500000 then
			speed <= speed - 1; -- update speed counter every 0.5 seconds, when speed reaches 0, the snake grows.
			skill <= skill + 1;
			cnt := 0;
			if (next_direction = current_direction) then
				if (current_direction = "001") then  -- moving vertical 
					body_character <= to_unsigned(3*8, 13); -- vertical character
					head_cell <= next_head_cell;
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
					WE_head <= '1';
					write_data_head <= current_direction & body_character;
					elsif (current_direction = "010") then -- moving right
					body_character <= to_unsigned(2*8, 13); -- horizontal character
					head_cell <= next_head_cell;
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
					WE_head <= '1';
					write_data_head <= current_direction & body_character;
					elsif (current_direction = "011") then -- moving down
					body_character <= to_unsigned(3*8, 13); -- vertical character
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
					head_cell <= next_head_cell;
					WE_head <= '1';
					write_data_head <= current_direction & body_character;
					elsif (current_direction = "100") then -- moving right
					body_character <= to_unsigned(2*8, 13); -- horizontal character
					head_cell <= next_head_cell;
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
					WE_head <= '1';
					write_data_head <= current_direction & body_character;					
				end if;
			else	
				if (current_direction = "001") then
				   if (next_direction = "010") then
					body_character <= to_unsigned(6*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
					current_direction <= "010";
					elsif (next_direction = "100") then
					body_character <= to_unsigned(7*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
					current_direction <= "100";
					end if;
					head_cell <= next_head_cell;
					WE_head <= '1';
					write_data_head <= Direction & body_character;
				elsif (current_direction = "011") then
					if (next_direction = "010") then
					body_character <= to_unsigned(4*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
					current_direction <= "010";
					elsif (next_direction = "100") then
					body_character <= to_unsigned(5*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
					current_direction <= "100";
					end if;
					head_cell <= next_head_cell;
					WE_head <= '1';
					write_data_head <= Direction & body_character;	
				elsif (current_direction = "010") then
					if (next_direction = "001") then
					body_character <= to_unsigned(4*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
					current_direction <= "001";
					elsif (next_direction = "011") then
					body_character <= to_unsigned(5*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
					current_direction <= "011";
					end if;
					head_cell <= next_head_cell;
					WE_head <= '1';
					write_data_head <= Direction & body_character;	
				elsif (current_direction = "100") then
					if (next_direction = "001") then
					body_character <= to_unsigned(4*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
					current_direction <= "001";
					elsif (next_direction = "011") then
					body_character <= to_unsigned(5*8, body_character'length);
					next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
					current_direction <= "011";
					end if;
					head_cell <= next_head_cell;
					WE_head <= '1';
					write_data_head <= Direction & body_character;						
				end if;
			
			end if;
			
		end if;

		  if (speed = 0) then
			speed <= "11111" - skill;
			
			end if;
			
			if (WE_head = '1') then
				WE_head <= '0';
				input_a_int <= write_data_head;
				address_a_int <= head_cell;
				write_enable <= '1';
			end if;
			
		end if;
 
 end process p_movesnake;


end Behavioral;

