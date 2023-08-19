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
