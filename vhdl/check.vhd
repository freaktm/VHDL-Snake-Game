--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the check logic for the snake physics.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.gamelogic_pkg.all;

entity check_logic is
  port(
    gamelogic_state       : in  gamelogic_state_t;
    clk_slow              : in  std_logic;
    ext_reset             : in  std_logic;
    address_a_check       : out unsigned(12 downto 0);
    check_read_data       : in  unsigned(11 downto 0);
    check_done            : out std_logic;
    keyboard              : in  unsigned(2 downto 0);
    crashed               : out std_logic;
    nochange              : out std_logic;
    current_direction_out : out unsigned(2 downto 0);
    old_direction_out     : out unsigned(2 downto 0);
    next_cell             : out unsigned(12 downto 0);
    corner_cell           : out unsigned(12 downto 0)
    );
end check_logic;

architecture Behavioral of check_logic is

  signal   current_direction_int : unsigned(2 downto 0)  := "001";
  signal   next_direction        : unsigned(2 downto 0)  := "001";
  signal   current_cell          : unsigned(12 downto 0) := to_unsigned(2520, 13);
  signal   next_cell_int         : unsigned(12 downto 0) := to_unsigned(2360, 13);
  signal   corner_cell_int       : unsigned(12 downto 0) := (others => '0');
  signal   old_direction_out_int : unsigned(2 downto 0)  := "001";
  signal   nochange_int          : std_logic             := '1';
  signal   crashed_int           : std_logic             := '0';
  signal   check_done_int        : std_logic             := '0';
  constant KEYBOARD_LEFT         : unsigned(2 downto 0)  := "100";
  constant KEYBOARD_RIGHT        : unsigned(2 downto 0)  := "010";
  constant KEYBOARD_UP           : unsigned(2 downto 0)  := "001";
  constant KEYBOARD_DOWN         : unsigned(2 downto 0)  := "011";


  type   current_axis_t is (HORIZONTAL, VERTICAL);
  type   check_state_t is (IDLE, CHECK_DIRECTION, MOVE_DIRECTION, CHECK_HIT);
  signal check_state  : check_state_t  := IDLE;
  signal current_axis : current_axis_t := VERTICAL;
  
begin


  old_direction_out     <= old_direction_out_int;
  current_direction_out <= current_direction_int;
  address_a_check       <= next_cell_int;
  nochange              <= nochange_int;
  crashed               <= crashed_int;
  corner_cell           <= corner_cell_int;
  check_done            <= check_done_int;


  next_direction <= keyboard;
  next_cell      <= next_cell_int;





  --purpose: checks if the snake has crashed into a border or itself
  --type   : sequential
  --inputs : clk25, ext_reset, state, next_direction, output_a_int, crash_result_ready
  --outputs: crash_test, crashed
  p_collision_checker : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
      
      crashed_int    <= '0';
      check_done_int <= '0';
      nochange_int   <= '1';
      current_axis   <= VERTICAL;

      current_cell          <= to_unsigned(2440, current_cell'length);
      current_direction_int <= KEYBOARD_UP;  -- reset to moving up
      next_cell_int         <= to_unsigned(2360, next_cell_int'length);

      old_direction_out_int <= KEYBOARD_UP;
      corner_cell_int       <= (others => '0');
      check_state           <= IDLE;
      
    elsif (clk_slow'event and clk_slow = '1') then
      if (gamelogic_state = CHECK) then
        if (check_state = IDLE) then
          if (current_direction_int /= next_direction) then
            if (current_axis = VERTICAL) then
              if (next_direction = KEYBOARD_RIGHT) or (next_direction = KEYBOARD_LEFT) then
                old_direction_out_int <= current_direction_int;
                corner_cell_int       <= current_cell;
                nochange_int          <= '0';
                check_state           <= CHECK_DIRECTION;
              end if;
            elsif (next_direction = KEYBOARD_UP) or (next_direction = KEYBOARD_DOWN) then
              old_direction_out_int <= current_direction_int;
              corner_cell_int       <= current_cell;
              nochange_int          <= '0';
              check_state           <= CHECK_DIRECTION;
            end if;
          else
            check_state  <= CHECK_DIRECTION;
            nochange_int <= '1';
          end if;
        elsif (check_state = CHECK_DIRECTION) then
          current_direction_int <= next_direction;
          check_state           <= MOVE_DIRECTION;
        elsif (check_state = MOVE_DIRECTION) then
          check_state <= CHECK_HIT;
          if (next_direction = KEYBOARD_UP) then
            current_axis  <= VERTICAL;
            next_cell_int <= to_unsigned(to_integer(current_cell) - 80, next_cell_int'length);
          elsif (next_direction = KEYBOARD_RIGHT) then
            current_axis  <= HORIZONTAL;
            next_cell_int <= to_unsigned(to_integer(current_cell) + 1, next_cell_int'length);
          elsif (next_direction = KEYBOARD_DOWN) then
            current_axis  <= VERTICAL;
            next_cell_int <= to_unsigned(to_integer(current_cell) + 80, next_cell_int'length);
          elsif (next_direction = KEYBOARD_LEFT) then
            current_axis  <= HORIZONTAL;
            next_cell_int <= to_unsigned(to_integer(current_cell) - 1, next_cell_int'length);
          end if;
        elsif (check_state = CHECK_HIT) then
          check_state <= IDLE;
          if (to_integer(check_read_data) = 0) then
            check_done_int <= '1';
          else
            crashed_int <= '1';
          end if;
        else
          check_state    <= IDLE;
          current_cell   <= next_cell_int;
          crashed_int    <= '0';
          check_done_int <= '0';
          nochange_int   <= '1';
        end if;
      end if;
    end if;
  end process p_collision_checker;



end Behavioral;
