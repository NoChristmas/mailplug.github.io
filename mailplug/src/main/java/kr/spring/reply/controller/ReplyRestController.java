package kr.spring.reply.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kr.spring.board.controller.BoardRestController;
import kr.spring.board.service.BoardService;
import kr.spring.reply.service.ReplyService;
import kr.spring.reply.vo.ReplyVO;

@RestController
public class ReplyRestController {
	private static final Logger logger = LoggerFactory.getLogger(BoardRestController.class);
	
	@Resource
	private ReplyService replyService;
	
	@GetMapping("/board/replyList/{board_num}")
	public Map<String, Object> getList(@PathVariable("board_num") int board_num) {
		logger.debug("<<board_num>> : " + board_num);
		

		Map<String, Object> mapJson = new HashMap<String, Object>();
		mapJson.put("board_num", board_num);

		
		List<ReplyVO> list = null;
		
		list = replyService.selectListReply(mapJson);
		mapJson.put("result", "success");
		mapJson.put("list", list);

		return mapJson;
	}
	
	@PostMapping("/board/writeReply")
	public Map<String, String> writeReply(@RequestBody ReplyVO replyVO, HttpSession session, HttpServletRequest request) {
		Map<String, String> mapJson = new HashMap<String, String>();
		replyVO.setUser_ip(request.getRemoteAddr());
		logger.debug("<<댓글 등록>> : " + replyVO);
		replyService.submitReply(replyVO);
		mapJson.put("result", "success");
		return mapJson;
	}
	
	@PutMapping("/board/replyFix")
	public Map<String, String> fixReply(@RequestBody ReplyVO replyVO, HttpSession session,  HttpServletRequest request) {

		logger.debug("<<ReplyFix>> : " + replyVO);
		Map<String, String> mapJson = new HashMap<String, String>();
		replyVO.setUser_ip(request.getRemoteAddr());

		// 댓글 수정
		replyService.fixReply(replyVO);
		mapJson.put("result", "success");
		return mapJson;
	}
	
	@DeleteMapping("/board/deleteReply/{reply_num}")
	public Map<String, String> deleteReply(@PathVariable int reply_num, HttpSession session) {
		logger.debug("<<reply_num>> : " + reply_num);
		Map<String, String> mapJson = new HashMap<String, String>();
		replyService.deleteReply(reply_num);
		mapJson.put("result", "success");
		return mapJson;
	}
	
}
