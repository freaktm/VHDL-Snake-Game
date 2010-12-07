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
-- Anthonix
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

use work.gamelogic_pkg.all;

entity game_logic is
  port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    ram_WEA       : out std_logic;
    ram_EN        : out std_logic;
    ram_address_a : out unsigned(12 downto 0) := "0000000000000";
    ram_input_a   : out unsigned(15 downto 0) := "0000000000000000";
    ram_output_a  : in  unsigned(15 downto 0) := "0000000000000000";
    Direction     : in  unsigned(2 downto 0)
    );
end game_logic;

architecture Behavioral of game_logic is


  component ram_mux is
    port(
      gamelogic_state   : in  gamelogic_state_t;
      WEA               : out std_logic;
      address_a         : out unsigned(12 downto 0);
      input_a           : out unsigned(15 downto 0);
      request_read      : in  std_logic;
      head_write_data   : in  unsigned(15 downto 0);
      head_cell         : in  unsigned(12 downto 0);
      corner_write_data : in  unsigned(15 downto 0);
      corner_cell       : in  unsigned(12 downto 0);
      tail_write_data   : in  unsigned(15 downto 0);
      tail_cell         : in  unsigned(12 downto 0);
      score_write_data  : in  unsigned(15 downto 0);
      score_cell        : in  unsigned(12 downto 0);
      reset_data        : in  unsigned(15 downto 0);
      reset_cell        : in  unsigned(12 downto 0)
      );
  end component;


  component head_logic is
    port(
      clk25          : in  std_logic;
      ext_reset      : in  std_logic;
      address_a_head : out unsigned(12 downto 0);
      input_a_head   : out unsigned(15 downto 0);
      output_a_head  : in  unsigned(15 downto 0);
      head_done      : out std_logic;
      reset_en       : out std_logic;
      request_read   : out std_logic
      );
  end component;

  signal tick       : std_logic;
  signal reset_en_int    : std_logic;
  signal head_en_int     : std_logic;
  signal tail_en_int     : std_logic;
  signal corner_en_int   : std_logic;
  signal score_en_int    : std_logic;
  signal reset_done_int  : std_logic;
  signal head_done_int   : std_logic;
  signal tail_done_int   : std_logic;
  signal score_done_int  : std_logic;
  signal crashed_int     : std_logic;
  signal corner_done_int : std_logic;



--  signal head_cell                                  : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2440
--  signal tail_cell                                  : unsigned(12 downto 0)        := to_unsigned(2520, 13);  -- cell 2520 (cell below head cell)
--  signal corner_cell                                : unsigned(12 downto 0);
--  signal score1_cell                                : unsigned(12 downto 0);
--  signal score2_cell                                : unsigned(12 downto 0);
--  signal score3_cell                                : unsigned(12 downto 0);
--  signal score4_cell                                : unsigned(12 downto 0);
--  signal next_head_cell                             : unsigned(12 downto 0)        := to_unsigned(2360, 13);  -- cell 2360
--  signal next_tail_cell                             : unsigned(12 downto 0)        := to_unsigned(2440, 13);  -- cell 2360
--  -- signal clearcell : unsigned(12 downto 0) := to_unsigned(0, 13);
--  signal speed                                      : unsigned(4 downto 0)         := "11111";  -- slowest speed
--  signal score                                      : unsigned(13 downto 0);
--  signal color                                      : unsigned (1 downto 0);
--  signal current_direction                          : unsigned(2 downto 0);
--  signal skill                                      : unsigned(4 downto 0)         := "00000";  -- skill 0
--  signal WE_head                                    : std_logic;
--  signal WE_tail                                    : std_logic;
--  signal WE_corner                                  : std_logic;
--  signal WE_score1, WE_score2, WE_score3, WE_score4 : std_logic                    := '0';  -- registers for the cell updater
--  signal next_direction                             : unsigned(2 downto 0);
--  signal body_character                             : unsigned(12 downto 0)        := to_unsigned(3*8, 13);
--  signal old_body_character                         : unsigned(12 downto 0);
--  signal write_data_head                            : unsigned(15 downto 0);
--  signal write_data_tail                            : unsigned(15 downto 0);
--  signal write_data_corner                          : unsigned(15 downto 0);
--  signal write_data_score1                          : unsigned(15 downto 0);
--  signal write_data_score2                          : unsigned(15 downto 0);
--  signal write_data_score3                          : unsigned(15 downto 0);
--  signal write_data_score4                          : unsigned(15 downto 0);
--  signal write_enable                               : std_logic;
--  signal write_job                                  : std_logic_vector(2 downto 0) := "000";  -- signal for cell update pipeline
--  signal crash_check                                : std_logic                    := '0';  -- register to activate the  crash checker
--  signal crash_test                                 : std_logic_vector(1 downto 0) := "00";  -- crash check pipeline
--  signal crashed                                    : std_logic                    := '0';  -- register to activate the crashed state
--  signal reset_game                                 : std_logic                    := '0';  -- register to restart game
--  signal game_reset                                 : std_logic                    := '0';  -- register to signal end of reset
--  signal move_snake                                 : std_logic                    := '0';  -- when timer reaches max he snake is moved.
--

  --- LOGIC STATE MACHINE SIGNALS

  signal logic_state : gamelogic_state_t;

  signal request_read_int      : std_logic;
  signal head_write_data_int   : unsigned(15 downto 0);
  signal head_cell_int         : unsigned(12 downto 0);
  signal corner_write_data_int : unsigned(15 downto 0);
  signal corner_cell_int       : unsigned(12 downto 0);
  signal tail_write_data_int   : unsigned(15 downto 0);
  signal tail_cell_int         : unsigned(12 downto 0);
  signal score_write_data_int  : unsigned(15 downto 0);
  signal score_cell_int        : unsigned(12 downto 0);
  signal reset_data_int        : unsigned(15 downto 0);
  signal reset_cell_int        : unsigned(12 downto 0);
  
begin



  RAM_CNTRL : ram_mux
    port map (
      gamelogic_state   => gamelogic_state,
      WEA               => ram_WEA,
      address_a         => ram_address_a,
      input_a           => ram_input_a,
      request_read      => request_read_int,
      head_write_data   => head_write_data_int,
      head_cell         => head_cell_int,
      corner_write_data => corner_write_data_int,
      corner_cell       => corner_cell_int,
      tail_write_data   => tail_write_data_int,
      tail_cell         => tail_cell_int,
      score_write_data  => score_write_data_int,
      score_cell        => score_cell_int,
      reset_data        => reset_data_int,
      reset_cell        => reset_cell_int);


  HEAD_CNTRL : head_logic
    port map (
      clk25          => clk25,
      ext_reset      => ext_reset,
      address_a_head => address_a_head_int,
      input_a_head   => input_a_head_int,
      output_a_head  => output_a_head_int,
      head_done      => head_done_int,
      reset_en       => reset_en_int,
      request_read   => request_read_int);

  EN_int <= '1';
  
 
  p_tick_timer : process (clk25, ext_reset)
    variable cnt : integer;
begin 
    if (ext_reset = '1') then   --asynchronous reset (active high)
      tick <= '0';
    elsif clk25'event and clk25 = '1' then        --    rising clock edge   
      cnt := cnt + 1;
      if (cnt = 5000000) then
        tick <= '1'; --  move snake head every time the  timer reaches max.
        cnt        := 0;
      else
        tick <= '0';
      end if;
		end if;
    end process p_tick_timer;



-- purpose: controls which state the game logic is in
-- type   : sequential
-- inputs : clk25, ext_reset, tick, head_done, corner_done, corner, score, tail_done, crashed, reset_done
-- outputs: state
  p_state_machine : process (clk25, ext_reset)
  begin  -- process p_state_machine
    if ext_reset = '1' then                 -- asynchronous reset (active high)
      state <= IDLE;
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      case logic_state is
        when IDLE =>
          if tick = '1' then
            logic_state <= HEAD;
          end if;
        when HEAD =>
          if (head_done = '1') and (corner_en = '1') then
            logic_state <= CORNER;
          elsif (head_done = '1') and (corner_en = '0') then
            logic_state <= TAIL;
          elsif (crashed = '1') then
            logic_state <= RESET;
          end if;
        when CORNER =>
          if (corner_done = '1') then
            logic_state <= TAIL;
          end if;
        when TAIL =>
          if (tail_done = '1') and (score_en = '0') then
            logic_state <= IDLE;
          elsif (tail_done = '1') and (score_en = '1') then
            logic_state <= SCORE;
          end if;
        when SCORE =>
          if (score_done = '1') then
            logic_state <= IDLE;
          end if;
        when RESET =>
          if (reset_done = '1') then
            logic_state <= IDLE;
          end if;
      end case;
    end if;

  end process p_state_machine;


-- purpose : enable head signal
-- type   : combinational
-- inputs : state
-- outputs: head_en
  p_head_en : process (state)
  begin  -- process p_head_en
    if state = HEAD then
      head_en <= '1';
    else
      head_en <= '0';
    end if;
  end process p_head_en;

-- purpose: enable tail signal
-- type   : combinational
-- inputs : state
-- outputs: tail_en
  p_tail_en : process (state)
  begin  -- process p_tail_en
    if state = TAIL then
      tail_en <= '1';
    else
      tail_en <= '0';
    end if;
  end process p_tail_en;


-- purpose: enable corner signal
-- type   : combinational
-- inputs : state
-- outputs: corner_en
  p_corner_en : process (state)
  begin  -- process p_corner_en
    if state = CORNER then
      corner_en <= '1';
    else
      corner_en <= '0';
    end if;
  end process p_corner_en;


-- purpose: enable score signal
-- type   : combinational
-- inputs : state
-- outputs: score_en
  p_score_en : process (state)
  begin  -- process p_score_en
    if state = SCORE then
      score_en <= '1';
    else
      score_en <= '0';
    end if;
  end process p_score_en;

-- purpose: enables game over signal
-- type   : combinational
-- inputs : state
-- outputs: reset_en
  p_reset_en : process (state)
  begin  -- process p_reset_en
    if state = RESET then
      reset_en <= '1';
    else
      reset_en <= '0';
    end if;
  end process p_reset_en;




-- purpose: updates the user input from keyboard
-- type   : sequential
-- inputs : clk25, ext_reset, Direction, crashed
-- outputs: next_direction, reset_game
--  p_keyboard_input : process (clk25, ext_reset)
--  begin   process p_keyboard_input
--    if ext_reset = '0' then                  asynchronous reset (active low)
--      next_direction = (others => '0');
--    elsif clk25'event and clk25 = '1' then   rising clock edge
-- update keyboard input      
--      if (Direction /= "000") and (Direction /= "101") then
--        next_direction <= Direction;
--      elsif (Direction = "101") and (crashed = '1') then
--        next_direction <= "111";
--      end if;
-- end of keyboard update
--    end if;
--  end process p_keyboard_input;




-- purpose: checks if the snake has crashed into a border or itself
-- type   : sequential
-- inputs : clk25, ext_reset, crash_check, next_head_cell, output_a_int, crash_result_ready
-- outputs: crash_test, crashed
--      p_collision_checker : process (clk25, ext_reset, game_reset)
--      begin   process p_collision_checker
--        if (ext_reset = '0') or (game_reset = '0') then   asynchronous reset (active low)
--          crash_test <= (others => '0');
--          crashed    <= '0';
--        elsif clk25'event and clk25 = '1' then            rising clock edge



--          if (crash_check = '1') then
--            if (crash_test = "00") then
--                  address_a_int  <= next_head_cell;
--              crash_test <= "01";
--            elsif (crash_result_ready = '1') then
--              crash_test <= (others => '0');
--              if (to_integer(output_a_int) /= 0) then
--                crashed <= '1';
--              else
--                crashed <= '0';
--              end if;
--            end if;
--          end if;
--        end if;
--      end process p_collision_checker;






--      p_movesnake : process (clk25, ext_reset, game_reset)

--      begin
--        if (ext_reset = '1') or (game_reset = '1') then  -- asynchronous reset (active low)
--          current_direction <= (others => '0');
--          --     speed             <= (others => '0');     -- slowest speed
--          --     skill             <= (others => '0');          -- lowest skill
--          body_character    <= to_unsigned(3*8, 13);     --     
--          WE_corner         <= '0';
--          WE_tail           <= '0';
--          WE_score1         <= '0';
--          WE_score2         <= '0';
--          WE_score3         <= '0';
--          WE_score4         <= '0';
--          write_data_corner <= (others => '0');
--          write_data_tail   <= (others => '0');
--          write_data_score1 <= (others => '0');
--          write_data_score2 <= (others => '0');
--          write_data_score3 <= (others => '0');
--          write_data_score4 <= (others => '0');
--          crash_check       <= '0';
--          reset_game        <= '0';
--          next_head_cell    <= to_unsigned(2360, head_cell'length);
--          write_data_head   <= current_direction & body_character;
--          WE_head           <= '1';
--          corner_cell       <= (others => '0');





--          if (move_snake = '0') then
--            WE_head     <= '1';
--            crash_check <= '1';
--            if (next_direction = current_direction) then  -- IF NO CHANGE IN DIRECTION
--              if (current_direction = "001") then  -- moving vertical
--                next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
--              elsif (current_direction = "010") then      -- moving right
--                next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
--              elsif (current_direction = "011") then      -- moving down
--                next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
--              elsif (current_direction = "100") then      -- moving right
--                next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
--              end if;
--              write_data_head <= current_direction & body_character;
--            else
--              if (current_direction = "001") then  -- IF moving UP before change
--                if (next_direction = "010") then   -- turns RIGHT
--                  old_body_character <= to_unsigned(6*8, body_character'length);
--                  body_character     <= to_unsigned(2*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
--                  current_direction  <= "010";
--                  WE_corner          <= '1';
--                elsif (next_direction = "100") then       -- turns LEFT
--                  old_body_character <= to_unsigned(7*8, body_character'length);
--                  body_character     <= to_unsigned(2*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
--                  current_direction  <= "100";
--                  WE_corner          <= '1';
--                else
--                  next_head_cell <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
--                end if;

--              elsif (current_direction = "011") then  -- IF moving DOWN befoe change
--                if (next_direction = "010") then      -- turns RIGHT
--                  old_body_character <= to_unsigned(5*8, body_character'length);
--                  body_character     <= to_unsigned(2*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
--                  current_direction  <= "010";
--                  WE_corner          <= '1';
--                elsif (next_direction = "100") then   -- turns  LEFT
--                  old_body_character <= to_unsigned(4*8, body_character'length);
--                  body_character     <= to_unsigned(2*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
--                  current_direction  <= "100";
--                  WE_corner          <= '1';
--                else
--                  --      body_character <= to_unsigned(3*8, body_character'length);
--                  next_head_cell <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
--                end if;

--              elsif (current_direction = "010") then  -- IF moving RIGHT before change
--                if (next_direction = "001") then      -- turns UP
--                  old_body_character <= to_unsigned(5*8, body_character'length);
--                  body_character     <= to_unsigned(3*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
--                  current_direction  <= "001";
--                  WE_corner          <= '1';
--                elsif (next_direction = "011") then   -- turns  DOWN
--                  old_body_character <= to_unsigned(7*8, body_character'length);
--                  body_character     <= to_unsigned(3*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
--                  current_direction  <= "011";
--                  WE_corner          <= '1';
--                else
--                  --    body_character <= to_unsigned(2*8, body_character'length);
--                  next_head_cell <= to_unsigned(to_integer(next_head_cell) + 1, next_head_cell'length);
--                end if;

--              elsif (current_direction = "100") then  -- IF moving LEFT before change
--                if (next_direction = "001") then      -- turns UP
--                  old_body_character <= to_unsigned(4*8, body_character'length);
--                  body_character     <= to_unsigned(3*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) - 80, next_head_cell'length);
--                  current_direction  <= "001";
--                  WE_corner          <= '1';
--                elsif (next_direction = "011") then   --turns DOWN
--                  old_body_character <= to_unsigned(6*8, body_character'length);
--                  body_character     <= to_unsigned(3*8, body_character'length);
--                  next_head_cell     <= to_unsigned(to_integer(next_head_cell) + 80, next_head_cell'length);
--                  current_direction  <= "011";
--                  WE_corner          <= '1';
--                else
--                  next_head_cell <= to_unsigned(to_integer(next_head_cell) - 1, next_head_cell'length);
--                end if;

--              end if;
--              write_data_corner <= Direction & old_body_character;
--              write_data_head   <= Direction & body_character;
--              corner_cell       <= head_cell;
--            end if;

--          end if;
--        end if;

--      end process p_movesnake;








end Behavioral;

