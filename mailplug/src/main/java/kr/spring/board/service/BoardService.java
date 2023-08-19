package kr.spring.board.service;

import java.util.List;
import java.util.Map;

import kr.spring.board.vo.BoardVO;

public interface BoardService {
	
	public void submitBoard(BoardVO boardVO);
	
	public int boardListCount();
	public List<BoardVO> viewAllBoard(Map<String,Object> map);
	
	public void fixBoard(BoardVO boardVO);
	
	public void deleteBoard(int board_num); 
	
	public List<BoardVO> viewBoardByBoardNum(Map<String, Object> mapJson);
	
	public int currentHit(int board_num);
	
	public void updateHit(int board_hit,int board_num);
}
