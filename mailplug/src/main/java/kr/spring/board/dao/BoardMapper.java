package kr.spring.board.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import kr.spring.board.vo.BoardVO;

@Mapper
public interface BoardMapper {
	
	@Insert("INSERT INTO MAILPLUG_BOARD (user_ip, user_nickname, board_passwd, board_title, board_info) VALUES (#{user_ip}, #{user_nickname}, #{board_passwd}, #{board_title}, #{board_info})")
	public void submitBoard(BoardVO boardVO);
	
	@Select("SELECT * FROM (SELECT a.*,rownum rnum FROM (SELECT * FROM MAILPLUG_BOARD ORDER BY board_num DESC)a) WHERE rnum>=#{startRow} AND rnum<= #{endRow}")
	public List<BoardVO> viewAllBoard(Map<String,Object> mapJson);
	
	@Select("SELECT COUNT(*) board_count FROM MAILPLUG_BOARD")
	public int boardListCount();
	
	@Select("SELECT * FROM MAILPLUG_BOARD WHERE board_num = #{board_num}")
	public List<BoardVO> viewBoardByBoardNum(Map<String, Object> mapJson);
	
	@Select("SELECT board_hit FROM MAILPLUG_BOARD WHERE board_num = #{board_num}")
	public int currentHit(int board_num);
	
	@Update("UPDATE MAILPLUG_BOARD SET board_hit = #{board_hit} WHERE board_num =#{board_num}")
	public void updateHit(int board_hit, int board_num);
	
	@Update("UPDATE MAILPLUG_BOARD SET user_ip = #{user_ip}, user_nickname = #{user_nickname}, board_title = #{board_title}, "
			+ "board_info = #{board_info}, board_passwd = #{board_passwd} WHERE board_num = #{board_num}")
	public void fixBoard(BoardVO boardVO);
	
	@Delete("DELETE FROM MAILPLUG_BOARD WHERE board_num = #{board_num}")
	public void deleteBoard(int board_num);
	
}
