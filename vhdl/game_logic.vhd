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
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
  port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    WEA_int       : out std_logic;
    EN_int        : out std_logic;
    address_a_int : out unsigned(12 downto 0) := "0000000000000";
    input_a_int   : out unsigned(15 downto 0) := "0000000000000000";
    output_a_int  : in  unsigned(15 downto 0) := "0000000000000000";
    colour        : out unsigned(1 downto 0);
    Direction     : in  unsigned(2 downto 0)
    );
end game_logic;

architecture Behavioral of game_logic is


  signal head_cell                                  : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2440
  signal tail_cell                                  : unsigned(12 downto 0)        := to_unsigned(2520, 13);  -- cell 2520 (cell below head cell)
  signal corner_cell                                : unsigned(12 downto 0);
  signal score1_cell                                : unsigned(12 downto 0);
  signal score2_cell                                : unsigned(12 downto 0);
  signal score3_cell                                : unsigned(12 downto 0);
  signal score4_cell                                : unsigned(12 downto 0);
  signal next_head_cell                             : unsigned(12 downto 0)        := to_unsigned(2360, 13);  -- cell 2360
  signal next_tail_cell                             : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2360
 -- signal clearcell : unsigned(12 downto 0) := to_unsigned(0, 13);
  signal speed                                      : unsigned(4 downto 0)         := "11111";  -- slowest speed
  signal score                                      : unsigned(13 downto 0);
  signal color                                      : unsigned (1 downto 0);
  signal current_direction                          : unsigned(2 downto 0);
  signal skill                                      : unsigned(4 downto 0)         := "00000";  -- skill 0
  signal WE_head                                    : std_logic;
  signal WE_tail                                    : std_logic;
  signal WE_corner                                  : std_logic;
  signal WE_score1, WE_score2, WE_score3, WE_score4 : std_logic                    := '0';  -- registers for the cell updater
  signal next_direction                             : unsigned(2 downto 0);
  signal body_character                             : unsigned(12 downto 0)        := to_unsigned(3*8, 13);
  signal old_body_character                         : unsigned(12 downto 0);
  signal write_data_head                            : unsigned(15 downto 0);
  signal write_data_tail                            : unsigned(15 downto 0);
  signal write_data_corner                          : unsigned(15 downto 0);
  signal write_data_score1                          : unsigned(15 downto 0);
  signal write_data_score2                          : unsigned(15 downto 0);
  signal write_data_score3                          : unsigned(15 downto 0);
  signal write_data_score4                          : unsigned(15 downto 0);
  signal write_enable                               : std_logic;
  signal write_job                                  : std_logic_vector(2 downto 0) := "000";  -- signal for cell update pipeline
  signal crash_check                                : std_logic                    := '0';  -- register to activate the  crash checker
  signal check_progress                             : std_logic_vector(1 downto 0) := "00";  -- crash check pipeline
  signal crashed                                    : std_logic                    := '0';  -- register to activate the crashed state
  signal reset_game : std_logic := '0';  -- register to restart game
  signal game_reset : std_logic := '0';  -- register to signal end of reset
  
begin

 


  EN_int  <= '1';
  colour  <= color;
  WEA_int <= write_enable;





  p_movesnake : process (clk25, ext_reset, game_reset)
    variable cnt : integer;
  begin
    if (ext_reset = '1') or (game_reset = '1') then             -- asynchronous reset (active low)
      current_direction <= "001";
      speed             <= "11111";     -- slowest speed
      skill             <= (others => '0');       -- lowest skill
      body_character    <= to_unsigned(2*8, 13);  -- 
      next_direction    <= "001";
      WE_head           <= '0';
      WE_corner         <= '0';
      WE_tail           <= '0';
      WE_score1         <= '0';
      WE_score2         <= '0';
      WE_score3         <= '0';
      WE_score4         <= '0';
      write_data_corner <= (others => '0');
      write_data_head   <= (others => '0');
      write_data_tail   <= (others => '0');
      write_data_score1 <= (others => '0');
      write_data_score2 <= (others => '0');
      write_data_score3 <= (others => '0');
      write_data_score4 <= (others => '0');
      crash_check       <= '0';
		reset_game <= '0';
					next_head_cell      <= to_unsigned(2360, head_cell'length);
		
				
    elsif clk25'event and clk25 = '1' then        -- rising clock edge


--update display buffer for ram writer process
      if (write_enable = '1') then
        if (write_job = "001") then
          WE_head <= '0';
        elsif (write_job = "010") then
          WE_corner <= '0';
        elsif (write_job = "011") then
          WE_tail <= '0';
        elsif (write_job = "100") then
          WE_score1 <= '0';
        elsif (write_job = "101") then
          WE_score2 <= '0';
        elsif (write_job = "110") then
          WE_score3 <= '0';
        elsif (write_job = "111") then
          WE_score4 <= '0';
        end if;
      end if;
		


-- update keyboard input
      if (Direction /= "000") then
        next_direction <= Direction;
		  if (Direction = "101") and (crashed = '1') then
		   reset_game <= '1';
			end if;
      end if;
-- end of direction update


--update crash check pipeline
      if (check_progress = "11") then
        crash_check <= '0';
      end if;

-- move snake head every 0.5 seconds.
      cnt := cnt + 1;
      if cnt = 7500000 then
        speed       <= speed - 1;  -- update speed counter every 0.5 seconds, when speed reaches 0, the snake grows.
        cnt         := 0;
        WE_head     <= '1';
        crash_check <= '1';
        if (next_direction = current_direction) then  -- IF NO CHANGE IN DIRECTION
          if (current_direction = "001") then     -- moving vertical
            body_character <= to_unsigned(3*8, 13);   -- vertical character
            next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
          elsif (current_direction = "010") then  -- moving right
            body_character <= to_unsigned(2*8, 13);   -- horizontal character
            next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
          elsif (current_direction = "011") then  -- moving down
            body_character <= to_unsigned(3*8, 13);   -- vertical character
            next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
          elsif (current_direction = "100") then  -- moving right
            body_character <= to_unsigned(2*8, 13);   -- horizontal character
            next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
          end if;
          write_data_head <= current_direction & body_character;
        else
          if (current_direction = "001") then     -- IF moving UP before change
            if (next_direction = "010") then      -- turns RIGHT
              old_body_character <= to_unsigned(6*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
              current_direction  <= "010";
              WE_corner          <= '1';
            elsif (next_direction = "100") then   -- turns LEFT
              old_body_character <= to_unsigned(7*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
              current_direction  <= "100";
              WE_corner          <= '1';
            else
              body_character <= to_unsigned(3*8, body_character'length);
              next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
            end if;
            body_character <= to_unsigned(2*8, body_character'length);
          elsif (current_direction = "011") then  -- IF moving DOWN befoe change
            if (next_direction = "010") then      -- turns RIGHT
              old_body_character <= to_unsigned(5*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
              current_direction  <= "010";
              WE_corner          <= '1';
            elsif (next_direction = "100") then   -- turns  LEFT
              old_body_character <= to_unsigned(4*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
              current_direction  <= "100";
              WE_corner          <= '1';
            else
              body_character <= to_unsigned(3*8, body_character'length);
              next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
            end if;
            body_character <= to_unsigned(2*8, body_character'length);
          elsif (current_direction = "010") then  -- IF moving RIGHT before change
            if (next_direction = "001") then      -- turns UP
              old_body_character <= to_unsigned(5*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
              current_direction  <= "001";
              WE_corner          <= '1';
            elsif (next_direction = "011") then   -- turns  DOWN
              old_body_character <= to_unsigned(7*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
              current_direction  <= "011";
              WE_corner          <= '1';
            else
              body_character <= to_unsigned(2*8, body_character'length);
              next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
            end if;
            body_character <= to_unsigned(3*8, body_character'length);
          elsif (current_direction = "100") then  -- IF moving LEFT before change
            if (next_direction = "001") then      -- turns UP
              old_body_character <= to_unsigned(4*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
              current_direction  <= "001";
              WE_corner          <= '1';
            elsif (next_direction = "011") then   --turns DOWN
              old_body_character <= to_unsigned(6*8, body_character'length);
              next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
              current_direction  <= "011";
              WE_corner          <= '1';
            else
              next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
            end if;
            body_character <= to_unsigned(3*8, body_character'length);
          end if;
          write_data_corner <= Direction & old_body_character;
          write_data_head   <= Direction & body_character;
        end if;
        
      end if;
    end if;
    
  end process p_movesnake;

  -- purpose: updates the ram entries for the video display
  -- type   : sequential
  -- inputs : clk25, ext_reset, WE_head, WE_tail, WE_corner, write_data_head,
  -- write_data_tail, write_data_corner, head_cell, corner_cell, tail_cell,
  -- WE_score1, WE_Score2, WE_score3, WE_score4, write_data_score1, write_data_score2, write_data_score3, write_data_score4
  -- outputs : address_a_int, write_enable, input_a_int, write_job
  p_cellupdate : process (clk25, ext_reset, game_reset)
  variable ramcnt_i : integer;
  variable ramcnt_j : integer;
  begin  -- process p_cellupdate
    if (ext_reset = '1') or (game_reset = '1') then             -- asynchronous reset (active high)
      write_job      <= (others => '0');
      head_cell      <= to_unsigned(2440, head_cell'length);
      tail_cell      <= to_unsigned(2440, tail_cell'length);
      check_progress <= (others => '0');
      crashed        <= '0';
				  ramcnt_i := 0;
		  ramcnt_j := 0;
		  write_enable <= '0';
		  game_reset <= '0';
			head_cell      <= to_unsigned(2440, head_cell'length);
			tail_cell      <= to_unsigned(2440, tail_cell'length);
		  crashed <= '0';
		  

		
    elsif clk25'event and clk25 = '1' then  -- rising clock edge  
	 if (reset_game ='1') then
		write_enable <= '1';
		input_a_int <= (others => '0');
		ramcnt_i := ramcnt_i + 1;
		if (ramcnt_i = 80) then
		 ramcnt_j := ramcnt_j + 1;
		 ramcnt_i := 0;		 
		 if (ramcnt_j = 55) then
		  game_reset <= '1';
		  end if;

		  
		 end if;
	    if (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
			  address_a_int <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_int'length );
			  input_a_int <= (others => '0');
		end if;
	

		end if;

      if (crashed = '1') then
      -- CRASHED STATE
       

        
      else      
      if (WE_head = '1') then
        -- Start of check to see if snake hit a border or itself.

        if (crash_check = '1') then
          if (check_progress = "00") then
            address_a_int  <= next_head_cell;
            check_progress <= "01";
          elsif (check_progress = "01") then
            if (to_integer(output_a_int) /= 0) then
              crashed <= '1';
            else
              crashed <= '0';
            end if;
            check_progress <= "11";
          else
            check_progress <= "00";
          end if;

        else
          write_job     <= "001";
          corner_cell   <= head_cell;
          input_a_int   <= write_data_head;
          head_cell     <= next_head_cell;
          address_a_int <= head_cell;
          write_enable  <= '1';
        end if;

      elsif (WE_corner = '1') then
        write_job     <= "010";
        input_a_int   <= write_data_corner;
        address_a_int <= corner_cell;
        write_enable  <= '1';
      elsif (WE_tail = '1') then
        write_job     <= "011";
        input_a_int   <= write_data_tail;
        address_a_int <= tail_cell;
        write_enable  <= '1';
      elsif (WE_score1 = '1') then
        write_job     <= "100";
        input_a_int   <= write_data_score1;
        address_a_int <= score1_cell;
        write_enable  <= '1';
      elsif (WE_score2 = '1') then
        write_job     <= "101";
        input_a_int   <= write_data_score2;
        address_a_int <= score2_cell;
        write_enable  <= '1';
      elsif (WE_score3 = '1') then
        write_job     <= "110";
        input_a_int   <= write_data_score3;
        address_a_int <= score3_cell;
        write_enable  <= '1';
      elsif (WE_score4 = '1') then
        write_job     <= "111";
        input_a_int   <= write_data_score4;
        address_a_int <= score4_cell;
        write_enable  <= '1';
      else
        write_enable <= '0';
        write_job    <= (others => '0');
      end if;
    end if;
    end if;
  end process p_cellupdate;



end Behavioral;

