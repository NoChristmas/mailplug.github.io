package kr.spring.reply.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.spring.reply.dao.ReplyMapper;
import kr.spring.reply.vo.ReplyVO;

@Service
@Transactional
public class ReplyServiceImpl implements ReplyService {
	@Autowired
	ReplyMapper replyMapper;
	
	@Override
	public void submitReply(ReplyVO replyVO) {
		replyMapper.submitReply(replyVO);
	}

	@Override
	public List<ReplyVO> selectListReply(Map<String, Object> mapJson) {
		return replyMapper.selectListReply(mapJson);
	}

	@Override
	public void deleteReply(int board_num) {
		replyMapper.deleteReply(board_num);
	}

	@Override
	public void fixReply(ReplyVO replyVO) {
		replyMapper.fixReply(replyVO);
	}

}