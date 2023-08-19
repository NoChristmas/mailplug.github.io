package kr.spring.reply.service;

import java.util.List;
import java.util.Map;

import kr.spring.reply.vo.ReplyVO;

public interface ReplyService {
	public void submitReply(ReplyVO replyVO);
	
	public List<ReplyVO> selectListReply(Map<String,Object> mapJson);
	
	public void deleteReply(int board_num);
	
	public void fixReply(ReplyVO replyVO);
}
