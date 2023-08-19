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

## BoardVO (게시판 VO)

```JAVA
public class BoardVO {
	private int board_num;
	private String user_ip;
	private String user_nickname;
	private String board_passwd;
	private String board_title;
	private String board_info;
	private int board_hit;
	private Date board_reg_date;
	//toString, Get, Set, import 생략

}
```
## ReplyVO (게시판 VO)
```JAVA
public class ReplyVO {
	private int reply_num;
	private String user_ip;
	private int board_num;
	private String reply_nickname;
	private String reply_info;
	private Date reply_reg_date;
	//toString, Get, Set, import 생략
}
```

## Mapper (게시판 마이바티스 Mapper)

```JAVA
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
```

## Mapper (댓글 마이바티스 Mapper)

```JAVA
package kr.spring.reply.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import kr.spring.reply.vo.ReplyVO;

@Mapper
public interface ReplyMapper {
	@Insert("INSERT INTO MAILPLUG_REPLY (user_ip, board_num, reply_nickname, reply_info) VALUES (#{user_ip}, #{board_num}, #{reply_nickname}, #{reply_info})")
	public void submitReply(ReplyVO replyVO);

	@Select("SELECT * FROM MAILPLUG_REPLY WHERE board_num = #{board_num}")
	public List<ReplyVO> selectListReply(Map<String, Object> mapJson);

	// board 제거 시 댓글들도 delete
	@Delete("DELETE FROM MAILPLUG_REPLY WHERE board_num = #{board_num}")
	public void deleteReplyByBoardNum(int board_num);

	// 댓글만 제거
	@Delete("DELETE FROM MAILPLUG_REPLY WHERE reply_num = #{reply_num}")
	public void deleteReply(int reply_num);

	@Update("UPDATE MAILPLUG_REPLY SET user_ip = #{user_ip}, reply_nickname = #{reply_nickname}, "
			+ "reply_info = #{reply_info} WHERE reply_num = #{reply_num}")
	public void fixReply(ReplyVO replyVO);

}
```
