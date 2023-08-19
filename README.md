# [MailPlug Subject]

메일플러그 과제에 대한 설명

## 개발 환경

1. 언어 : java(17)
2. DB : h2
3. FrameWork : spring boot (3 이상)

## BoardController (웹페이지를 뿌리는 Controller)
```JAVA
package kr.spring.board.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import kr.spring.board.service.BoardService;
import kr.spring.board.vo.BoardVO;

@Controller
public class BoardController {

	@Autowired
	BoardService boardService;

	@ModelAttribute
	public BoardVO initCommand() {
		return new BoardVO();
	}

	@RequestMapping("/")
	public String getFirstPage() {
		return "redirect:/board/main";
	}

	@GetMapping("/board/main")
	public ModelAndView getMainPage() {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("/board/main");
		return mav;
	}

	@GetMapping("/board/write")
	public String getWritePage() {
		return "/board/write";
	}

	@GetMapping("/board/detail")
	public ModelAndView getBoardDetail() {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("/board/detail");
		return mav;
	}

	@GetMapping("/board/fix")
	public String getFixPage() {
		return "/board/fix";
	}

}
```

## BoardRestController (게시판 관련 Rest API 형식 Controller)
```JAVA

package kr.spring.board.controller;

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
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import kr.spring.board.service.BoardService;
import kr.spring.board.vo.BoardVO;

@RestController
public class BoardRestController {
	private static final Logger logger = LoggerFactory.getLogger(BoardRestController.class);

	@Resource
	private BoardService boardService;

	@GetMapping("/board/countTotalBoard")
	public Map<String, Object> countTotalBoard() {
		Map<String, Object> mapJson = new HashMap<>();
		int count = boardService.boardListCount();
		mapJson.put("count", count);
		return mapJson;
	}

	// 메인 글 목록 가져오기
	@GetMapping("/board/outputboard/{startRow}/{endRow}")
	public Map<String, Object> getWriteForm(@PathVariable("startRow") int startRow, @PathVariable("endRow") int endRow,
			HttpSession session, HttpServletRequest request) {
		Map<String, Object> mapJson = new HashMap<>();
		List<BoardVO> list = null;
		int count = boardService.boardListCount();
		logger.debug("<<start, End>>" + startRow + "," + endRow);
		mapJson.put("startRow", startRow);
		logger.debug("<<count보기>>" + count);
		mapJson.put("endRow", endRow);
		// 댓글 등록
		list = boardService.viewAllBoard(mapJson);

		mapJson.put("result", "success");
		mapJson.put("count", count);
		mapJson.put("list", list);
		return mapJson;
	}

	// 디테일 글 목록 가져오기
	@GetMapping("/board/detail/{board_num}")
	public Map<String, Object> getDetailForm(@PathVariable("board_num") int board_num, HttpSession session,
			HttpServletRequest request) {
		Map<String, Object> mapJson = new HashMap<>();
		List<BoardVO> list = null;
		mapJson.put("board_num", board_num);
		// 댓글 등록
		list = boardService.viewBoardByBoardNum(mapJson);
		mapJson.put("result", "success");
		mapJson.put("list", list);
		return mapJson;
	}

	// 글 등록하기
	@PostMapping("/board/write")
	public Map<String, Object> submitWrite(@RequestBody BoardVO boardVO, HttpSession session,
			HttpServletRequest request) {

		logger.debug("<<글 등록>> : " + boardVO);
		Map<String, Object> mapJson = new HashMap<>();
		logger.debug("<<글 등록된 값들 보자>>" + boardVO);
		boardVO.setUser_ip(request.getRemoteAddr()); // ip등록
		boardService.submitBoard(boardVO); // 댓글 등록

		mapJson.put("result", "success");
		return mapJson;
	}

	@PutMapping("/board/fix")
	public Map<String, String> fixBoard(@RequestBody BoardVO boardVO, HttpSession session, HttpServletRequest request) {
		Map<String, String> mapJson = new HashMap<String, String>();
		// boardnum을 받아와야 한다.
		boardVO.setUser_ip(request.getRemoteAddr());

		logger.debug("<<BoardVO (board_fix)>> : " + boardVO);

		boardService.fixBoard(boardVO); // 수정 Mapper
		mapJson.put("result", "success");
		return mapJson;
	}

	@PutMapping("/board/updateHit/{board_num}")
	public Map<String, String> updateHit(@PathVariable int board_num) {
		Map<String, String> mapJson = new HashMap<>();
		int board_hit = boardService.currentHit(board_num);
		board_hit++;
		boardService.updateHit(board_hit, board_num);
		mapJson.put("result", "success");
		return mapJson;
	}

	@DeleteMapping("/board/delete/{board_num}")
	public Map<String, String> deleteReply(@PathVariable int board_num, HttpSession session) {

		if (logger.isDebugEnabled()) {
			logger.debug("<<board_num>> : " + board_num);
		}

		Map<String, String> mapJson = new HashMap<String, String>();

		// 로그인 되어 있고 로그인한 아이디와 작성자 아이디 일치
		boardService.deleteBoard(board_num);
		mapJson.put("result", "success");

		return mapJson;
	}

}
```

## ReplyRestController (댓글 관련 Rest API 형식 Controller)
```JAVA
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
```
