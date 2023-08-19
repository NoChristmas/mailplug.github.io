package kr.spring.board.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.spring.board.dao.BoardMapper;
import kr.spring.board.vo.BoardVO;
import kr.spring.reply.dao.ReplyMapper;

@Service
@Transactional
public class BoardServiceImpl implements BoardService {
	@Autowired
	BoardMapper boardMapper;

	@Autowired
	ReplyMapper replyMapper;

	@Override
	public void submitBoard(BoardVO boardVO) {
		boardMapper.submitBoard(boardVO);
	}

	@Override
	public List<BoardVO> viewAllBoard(Map<String, Object> mapJson) {
		return boardMapper.viewAllBoard(mapJson);
	}

	@Override
	public void fixBoard(BoardVO boardVO) {
		boardMapper.fixBoard(boardVO);
	}

	@Override
	public void deleteBoard(int board_num) {
		replyMapper.deleteReplyByBoardNum(board_num);
		boardMapper.deleteBoard(board_num);
	}

	@Override
	public List<BoardVO> viewBoardByBoardNum(Map<String, Object> mapJson) {
		return boardMapper.viewBoardByBoardNum(mapJson);
	}

	@Override
	public int boardListCount() {
		return boardMapper.boardListCount();
	}

	@Override
	public int currentHit(int board_num) {
		return boardMapper.currentHit(board_num);
	}

	@Override
	public void updateHit(int board_hit, int board_num) {
		boardMapper.updateHit(board_hit, board_num);
	}
}
