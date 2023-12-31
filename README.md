# [MailPlug Subject]

메일플러그 과제에 대한 설명

## 개발 환경

1. 언어 : java(17)
2. DB : h2
3. FrameWork : spring boot (3 이상)

## BoardController (웹페이지를 뿌리는 Controller)
```JAVA

@Controller
public class BoardController {

	@Autowired
	BoardService boardService;

	/*
	@ModelAttribute
	public BoardVO initCommand() {
		return new BoardVO();
	}
	*/
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
application.yml의 mvc 관련 view 경로 설정에 의해 return 값을 받을 때 경로를 /WEB-INF/views/리턴받은String값.jsp 의 경로를 내부에서 찾음


application.yml 파일 내용 >>
spring: 
  mvc:
    view: #view 경로 및 확장자 지정
      prefix: /WEB-INF/views/
      suffix: .jsp 


@Controller 어노테이션은 : MVC 중 Controller에 해당하며 User가 요청한 값들을 받아 jsp 경로를 뿌려준다. 


@AutoWired 어노테이션 : 의존성 주입으로 BoardService에 줌으로서 Service의 객체를 가져옴.


@ModelAttribute 어노테이션 : HTTP에사 넘어온 Query들을 자동으로 Binding 해준다. 또 List 형태로 jsp에 전달될 때도 같은 이름으로 전달됨.


@AutoWired와 @ModelAttribute 어노테이션은 위 설명한 Controller에서는 필요없는 객체로 판단됨.


## BoardRestController (게시판 관련 Rest API 형식 Controller)
```JAVA
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

	// 글 수정
	@PutMapping("/board/fix")
	public Map<String, String> fixBoard(@RequestBody BoardVO boardVO, HttpSession session, HttpServletRequest request) {
		Map<String, String> mapJson = new HashMap<String, String>();
		
		boardVO.setUser_ip(request.getRemoteAddr());

		logger.debug("<<BoardVO (board_fix)>> : " + boardVO);
		boardService.fixBoard(boardVO); // 수정 Mapper
		mapJson.put("result", "success");
		return mapJson;
	}

	// 조회수 증가
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
		boardService.deleteBoard(board_num);
		mapJson.put("result", "success");

		return mapJson;
	}

}
```
1. HTML 의 javaScript 에서 ajax로 Data값을 get, post, put, delete의 type으로 JSON 형태로 넘겨준다. 


2. @RestController의 각 @GET, @POST, @PUT, @DELETE의 어노테이션으로 물리고 해당 메서드에 들어오게 된다.


3. 각 url을 타고 들어온 뒤 /{board_num}을 javaScript로 부터 받게 되고, @PathVariable로 값을 식별한다. ("board_num")으로 감싸야 하지만 변수명이 같으므로 생략 가능


4. 값을 넘겨 받았으니 Service > ServiceImpl > DAO (Mapper)의 값을 가져온다음 int, List<boardVO> 형태로 담아서 오게 된다.


5. 각 받은 값들은 JSON 형태로 받고, success를 반환시 이를 HTML에 태그 추가 및 값들을 반복문을 써가며 리스트, 값들을 반환한다.




## ReplyRestController (댓글 관련 Rest API 형식 Controller)
```JAVA
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
위 설명과 동일한 방법으로 작동한다.



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
각 VO들의 변수는 key값이 되고, @Mapper로 들어가 JSON 형태인 { "key":"value" } 형태로 가져온다.
## Mapper (게시판 마이바티스 Mapper)
```JAVA
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
startRow와 endRow를 받는 것은 게시판의 페이징 처리를 위한 것이며 이는 연산이 필요하다. 


rnum은 DB에서 가상의 번호를 만들고, 이를 이용해 총 몇개씩 출력한 것인지 결정 하게 된다.

## Mapper (댓글 마이바티스 Mapper)
```JAVA
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
댓글의 경우는 게시글의 FK인 board_num를 받는 자식 테이블이므로, 댓글은 없어질 수 있으나 게시판 글이 지워지면 댓글을 지운 후에 게시판을 지워야 알맞다.


## main 페이지
```HTML
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"  %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>mailplug</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script type="text/javascript">
$(function(){
	let totalCount;
	$.ajax({
        type: "get",
        url: "${pageContext.request.contextPath}/board/countTotalBoard",
        success: function (param) {
        	totalCount = param.count;
        	console.log('totalCount = '+totalCount);
        	setPage(totalCount);
        },
        error: function() {
            alert('count 실패');
        }
	});
	
	let currentPage;	//현재 보고 있는 화면
	let pageSize = 5;	//화면에 보여줄 게시판 갯수
	let pageBlock = 10;	//페이지 표시 단위
	
	//6이 들어옴...
	function setPage(totalCount){
	  	console.log('페이지 처리 시작');
	  	console.log('개수:'+totalCount);
		
		$('.paging-btn').empty();
		if(totalCount == 0){
			return;
		}
		
		let totalPage = Math.ceil(totalCount/pageSize);
		
		if(currentPage == undefined || currentPage == ''){
			currentPage = 1;
		}
		//현재 페이지가 전체 페이지 수보다 크면 전체 페이지수로 설정
		if(currentPage > totalPage){
			currentPage = totalPage;
		}
		let startRow = (currentPage - 1) * pageSize + 1;
		let endRow = currentPage * pageSize;
		
		//시작 페이지와 마지막 페이지 값을 구하기
		let startPage = Math.floor((currentPage-1)/pageBlock)*pageBlock + 1;
		let endPage = startPage + pageBlock - 1;
		
		//마지막 페이지가 전체 페이지 수보다 크면 전체 페이지 수로 설정
		if(endPage > totalPage){
			endPage = totalPage;
		}
		
		let add='';
		if(startPage>pageBlock){
			add += '<li data-page='+(startPage-1)+'>&lt;</li>';
		}
		
		for(var i=startPage;i<=endPage;i++){
			add += '<li data-page='+i+'>'+i+'</li>';
		}
		if(endPage < totalPage){
			add += '<li data-page='+(startPage+pageBlock)+'>&gt;</li>';;
		}
		//ul 태그에 생성한 li를 추가
		$('.paging-btn').append(add);
		console.log("============function 안===========");
		console.log("totalPage = "+totalPage);
		console.log("startPage = " +startPage);
		console.log("endPage = "+endPage);
		console.log("currentPage = "+currentPage);
		console.log("pageSize = "+pageSize);
		console.log("pageBlock = "+pageBlock);
		console.log("startRow = "+startRow);
		console.log("endRow = "+endRow);
		console.log("============function 끝===========")
		
		//ajax 시작
		$('#board_contents').empty();
		$.ajax({
            type: "get",
            url: "${pageContext.request.contextPath}/board/outputboard/"+startRow+"/"+endRow,
            success: function (param) {
            	let boardStart = '<div>총 : '+param.count+' 개</div>';
            	boardStart += '<table><tr>';
            	boardStart += '<th>번호</th>';
            	boardStart += '<th>내용</th>';
            	boardStart += '<th>닉네임</th>';
            	boardStart += '<th>작성일</th>';
            	boardStart += '<th>조회수</th>';
            	boardStart += '</tr>';
        		$('#board_contents').append(boardStart);
            	$(param.list).each(function (index, item) {
	                let output = '<tr>';
					output += '<td>'+item.board_num+'</td>';
					output += '<td><a href="${pageContext.request.contextPath}/board/detail?board_num='+item.board_num+'">'+item.board_title+'</a></td>';
					output += '<td>'+item.user_nickname+'</td>';
					output += '<td>'+item.board_reg_date+'</td>';
					output += '<td>'+item.board_hit+'</td>';
					output += '</tr>';
	                $('#board_contents').append(output);
	            });
            	let boardEnd = '</table>';
            	$('#board_contents').append(boardEnd);
            	//setPage(param.count);
            	
            },
            error: function() {
                alert('ajax 실패');
            }
        });
	}  
	
	
	$(document).on('click','.paging-btn li',function(){
		//페이지 번호를 읽어들임
		currentPage = $(this).attr('data-page');
		//목록 호출
		setPage(totalCount);
	});
	
	
	
})
</script>
</head>
<body>
	<!-- 게시판 목록  -->
	<h2>메인 게시판</h2>
	<a href="${pageContext.request.contextPath}/board/write">글 쓰기</a>
	<!-- js에서 가져오는 값들 -->
	<div id="board_contents"></div>
	<div class="paging-box"><ul class="paging-btn"></ul></div>
</body>
</html>
```
상황에 맞게 jQuery문을 활용한 javascript를 써가며 $.ajax를 통해 서버와 통신하며 값들을 주고 받고 있다.


위 startRow, endRow 값을 연산하는 작업이 있는데 이는 4가지의 값을 필요로 한다.

totalCount (get을 통해서 값을 가져옴),


pageSize 한번에 보여줄 레코드 수,


pageBlock 한본에 보여줄 페이징 처리를 위한 번호,


currentPage (default 1페이지)


각 Paging을 누를 때 마다, startRow, endRow가 바뀌게 되며 이를 List로 받아와 화면에 뿌리게 된다.

## 세부 페이지
```HTML
타이틀 위 생략...
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script type="text/javascript">
jQuery.fn.serializeObject = function() {
    let obj = null;
    try {
        if (this[0].tagName && this[0].tagName.toUpperCase() == "FORM") {
            let arr = this.serializeArray();
            if (arr) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });
            }//if ( arr ) {
        }
    } catch (e) {
        alert(e.message);
    } finally {
    }
 
    return obj;
};


$(function(){
	const urlParams = new URLSearchParams(window.location.search);
	const board_num = urlParams.get("board_num");
	$('#board_num').val(board_num);	
	
	$.ajax({
           type: "put",
           url: "${pageContext.request.contextPath}/board/updateHit/"+board_num,
           success: function (param) {
           	    if(param.result == 'success') {
           	    	$.ajax({
           	         type: "get",
           	         url: "${pageContext.request.contextPath}/board/detail/"+board_num,
           	            success: function (param) {
           	            	$(param.list).each(function (index, item) {
           		                let output = '<div class="align-contents">';
           						output += '<div>번호 : '+item.board_num+' | 닉네임 : '+item.user_nickname+' | 등록 날짜 : '+item.board_reg_date+' | 조회수 : '+item.board_hit+'</div>';
           						output += '<div> 제목 : '+item.board_title+'</div>';
           						output += '<div> 내용 : '+item.board_info+'</div>';
           						output += '<div><a href="${pageContext.request.contextPath}/board/fix?board_num='+item.board_num+'">글 수정하기</a> | <a href="/board/main">Home</a></div>';
           						
           						output += '</div>';
           		                $('#contents_output').append(output);
           		                
           		                
           		            });
           	            	
           	            },
           	            error: function() {
           	                alert('ajax 실패');
           	            }
           	    	});
           	    }
           },
           error: function () {
               alert('fail');
           }
    });
	
	function getReplyList(){
		$.ajax({
	        type: "get",
	        url: "${pageContext.request.contextPath}/board/replyList/"+board_num,
	           success: function (param) {
	        	$('#reply_output').empty();  
	           	if(param.result == 'success') {
	           		$(param.list).each(function (index, item) {
		                let output = '<hr>';
	           			output += '<div class="align-contents">';
						output += '<div> 번호 : '+item.reply_num+'</div>';
						output += '<div class="reply_nickname" data-replynum="'+item.reply_num+'"> 작성자 : '+item.reply_nickname+' ('+item.user_ip+')</div>';
						output += '<div class="reply_info" data-replynum="'+item.reply_num+'">'+item.reply_info+'</div>';
						output += '<div class="virtualFormOutput" data-replynum="'+item.reply_num+'"></div>';
						output += '<div> 등록 날짜 ('+item.reply_reg_date+') | <span class="replyFix" data-replynum="'+item.reply_num+'">댓글 수정하기</span> | <span class="deleteReply" data-replynum="'+item.reply_num+'">삭제하기</span></div>';
						output += '</div>';
						$('#reply_output').append(output);
					});
	           		
	           		
	           		$('.deleteReply').click(function() {
	           	        let reply_num = $(this).data('replynum');
	           	        $.ajax({
	           	            type: "delete",
	           	            url: "${pageContext.request.contextPath}/board/deleteReply/" + reply_num,
	           	            success: function(param) {
	           	                alert('댓글이 삭제 됩니다.');
	           	                getReplyList();
	           	            },
	           	            error: function() {
	           	                alert('ajax 실패');
	           	            }
	           	        });
	           	    });
	           		
	           		$('.replyFix').click(function() {
	           		    let reply_num = $(this).data('replynum');
	           		    let replyVirtualOutputElement = $('.virtualFormOutput[data-replynum="' + reply_num + '"]');
	           		    let replyFormOutput = '<form method="post" class="reply-form" data-replynum="' + reply_num + '">';
	           		    replyFormOutput += '<input type="hidden" name="reply_num" value="'+reply_num+'">';
	           		    replyFormOutput += '<label for="reply_nickname_fix">닉네임</label>';
	           		    replyFormOutput += '<input type="text" id="reply_nickname_fix" name="reply_nickname" maxlength="16" required>';
	           		    replyFormOutput += '<label for="reply_info_fix">내용</label>';
	           		    replyFormOutput += '<textarea id="reply_info_fix" name="reply_info" maxlength="333" required></textarea>';
	           		    replyFormOutput += '<button type="submit" class="reply-submit-button">수정하기</button>';
	           		    replyFormOutput += '</form>';
	           		    
	           		    // 기존의 폼을 삭제하고 수정 폼을 추가합니다.
	           		    replyVirtualOutputElement.empty().append(replyFormOutput);

	           		    // 수정 폼 제출 시 처리 로직을 추가할 수 있습니다.
	           		    $('.reply-form[data-replynum="' + reply_num + '"]').submit(function(event) {
	           		    	event.preventDefault();
	           				let data = $(this).serializeObject();
	           				console.log(data);
	           				$.ajax({
	           		            type: "put",
	           		            url: "${pageContext.request.contextPath}/board/replyFix",
	           		            data: JSON.stringify(data),
	           		            contentType: "application/json; charset=utf-8", // 요청의 Content-Type 설정
	           		            dataType: "json", // 응답의 데이터 타입
	           		            success: function (param) {
	           		                
	           		            	alert('등록 성공');
	           		            	getReplyList();
	           		            	
	           		                $('#reply_output').empty();
	           		            	getReplyList();
	           		            	
	           		            },
	           		            error: function () {
	           		                alert('fail');
	           		            }
	           		        });
	           		    });
	           		});
	           		
	           	}
	       },
	       error: function() {
	           alert('ajax 실패');
	       }
	   }); 
	}
	
	
	$('#deleteBoard').click(function(){
		$.ajax({
	         type: "delete",
	         url: "${pageContext.request.contextPath}/board/delete/"+board_num,
	            success: function (param) {
	            	if(param.result == 'success') {
	            		alert('삭제 성공');
	            		window.location.href = '/board/main';
	            	}
	            	
	            },
	            error: function() {
	                alert('ajax 실패');
	            }
	    });
	});
	
	
	
	$('#form-submit').submit(function(event){
		event.preventDefault();
		let data = $(this).serializeObject();
		console.log(data);
		$.ajax({
            type: "post",
            url: "${pageContext.request.contextPath}/board/writeReply",
            data: JSON.stringify(data),
            contentType: "application/json; charset=utf-8", // 요청의 Content-Type 설정
            dataType: "json", // 응답의 데이터 타입
            success: function (param) {
                if(param.result == 'success') {
            		alert('등록 성공');
            		$('#reply_nickname').val('');
            		$('#reply_info').val('');
            	}
                $('#reply_output').empty();
            	getReplyList();
            	
            },
            error: function () {
                alert('fail');
            }
        });
    }); //end of reply submit
	
    getReplyList();

});
</script>
</head>
<body>
	<div class="main-box">
	<h2>글 내용</h2>
	<div id="contents_output"></div>
	<span id="deleteBoard">삭제하기</span>
	<div id="reply_output"></div>
	<hr>
	<div id="reply-box">	
		<form method="post" id="form-submit">
      	 	<input type="hidden" id="board_num" name="board_num">
      	 	
      	 	<label for="reply_nickname">닉네임</label>
      		<input type="text" id="reply_nickname" name="reply_nickname" maxlength="16" required>
        	
        	<label for="reply_info">내용</label>
      	 	<textarea id="reply_info" name="reply_info" maxlength="333" required></textarea>
       	  	<button type="submit" id="submit-button">댓글 등록</button>
    	</form>
	</div>
	</div>
</body>
</html>
```
보통 get이나 delete 방식은 바꾸는 값이 없기 때문에 큰 처리가 필요 없는데, put과 post의 경우는 각종 다양한 문자들이 들어오기 때문에, jQuery.fn.serializeObject 처리를 꼭 해줘야 한다.


해주지 않을 시 415 Error가 발생할 수 있다.


put이나 post의 경우 각 DB에 값들이 직접 이동하고 Write 된 다음 나오는 프로세스를 가지고 있다. 따라서 사전 처리 해야할 작업들이 좀 있다.

```HTML
<script>
jQuery.fn.serializeObject = function() {
    let obj = null;
    try {
        if (this[0].tagName && this[0].tagName.toUpperCase() == "FORM") {
            let arr = this.serializeArray();
            if (arr) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });
            }//if ( arr ) {
        }
    } catch (e) {
        alert(e.message);
    } finally {
    }
 
    return obj;
};

$('#form-submit').submit(function(event){
		event.preventDefault();
		let data = $(this).serializeObject();
		console.log(data);
		$.ajax({
            type: "post",
            url: "${pageContext.request.contextPath}/board/writeReply",
            data: JSON.stringify(data),
            contentType: "application/json; charset=utf-8", // 요청의 Content-Type 설정
            dataType: "json", // 응답의 데이터 타입
<script>
```
serializeObject 의 함수는 form 태그 안에 있는 태그들의 name을 key로, value를 value 값으로 가져온다. 


{ name: ..., value: ... } 형태로 가져와서  $.ajax로 해당 url: /board/writeReply 을 타고가 @PostMapping("/board/writeReply") 어노테이션을 만나게 되고 


데이터는 JSON 파일 형태로 요청의 Content-Type은 application/json 형태로 요청하여 json형태로 받아 html을 구성한다.
## 작성 페이지
```HTML
title 위 생략...
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script type="text/javascript">
jQuery.fn.serializeObject = function() {
    let obj = null;
    try {
        if (this[0].tagName && this[0].tagName.toUpperCase() == "FORM") {
            let arr = this.serializeArray();
            if (arr) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });
            }//if ( arr ) {
        }
    } catch (e) {
        alert(e.message);
    } finally {
    }
 
    return obj;
};

$(function(){
	

	$('#form-submit').submit(function(event){
        event.preventDefault();
		let data = $(this).serializeObject();
		console.log(data);
                
        // AJAX 요청
        $.ajax({
            type: "post",
            url: "${pageContext.request.contextPath}/board/write",
            data: JSON.stringify(data),
            contentType: "application/json; charset=utf-8", // 요청의 Content-Type 설정
            dataType: "json", // 응답의 데이터 타입
            success: function (param) {
                
            	if(param.result == 'success') {
            		alert('등록 성공');
            		window.location.href = '/board/main';
            	}
            	
            },
            error: function () {
                alert('fail');
            }
        });
    });
	
	
});
</script>
스타일 생략
</head>
<body>
	<div class="main-box">
		<h2>글 쓰기</h2>
		<form method="post" id="form-submit">
      	 	<label for="board_title">제목:</label>
      		<input type="text" id="board_title" name="board_title" required>
        	
        	<label for="user_nickname">닉네임 : </label>
       	 	<input type="text" id="user_nickname" name="user_nickname" required>
       	 	
     	 	<label for="board_info">내용:</label>
      	 	<textarea id="board_info" name="board_info" rows="4" cols="50" required></textarea>
       	  
      		<label for="board_passwd">비밀번호 : </label>
      		<input type="password" id="board_passwd" name="board_passwd" required>
        	<button type="submit" id="submit-button">등록하기</button>
    	</form>
    </div>
</body>
</html>
```
위와 동일한 방식으로 진행 되게 된다.

## 수정 페이지
```HTML
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>mailplug | 글 수정</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script type="text/javascript">
jQuery.fn.serializeObject = function() {
    let obj = null;
    try {
        if (this[0].tagName && this[0].tagName.toUpperCase() == "FORM") {
            let arr = this.serializeArray();
            if (arr) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });
            }//if ( arr ) {
        }
    } catch (e) {
        alert(e.message);
    } finally {
    }
 
    return obj;
};
$(function(){
	const urlParams = new URLSearchParams(window.location.search);
    const board_num = urlParams.get("board_num");
	$('#board_num').val(board_num);
	
	$('#form-submit').submit(function(event){
        event.preventDefault();
		let data = $(this).serializeObject();
		console.log(data);
                
        // AJAX 요청
        $.ajax({
            type: "put",
            url: "${pageContext.request.contextPath}/board/fix",
            data: JSON.stringify(data),
            contentType: "application/json; charset=utf-8", // 요청의 Content-Type 설정
            dataType: "json", // 응답의 데이터 타입
            success: function (param) {
                if(param.result == 'success') {
            		alert('수정 성공');
            		window.location.href = '/board/main';
            	}
            	
            },
            error: function () {
                alert('fail');
            }
        });
    });
	
});
</script>
스타일 생략
</head>
<body>
	<div class="main-box">
		<h2>수정하기</h2>
		<form method="post" id="form-submit">
			<input type="hidden" id ="board_num" name="board_num">
      	 	
      	 	<label for="board_title">제목</label>
      		<input type="text" id="board_title" name="board_title" maxLength="16" required>
        	
        	<label for="user_nickname">닉네임</label>
       	 	<input type="text" id="user_nickname" name="user_nickname" maxLength="16" required>
       	 	
     	 	<label for="board_info">내용</label>
      	 	<textarea id="board_info" name="board_info" maxLength="333" required></textarea>
       	  
      		<label for="board_passwd">비밀번호</label>
      		<input type="password" id="board_passwd" name="board_passwd" maxLength="16" required>
        	
        	<button type="submit" id="submit-button">등록하기</button>
    	</form>
    </div>
</body>
</html>
```
위와 같은 방식으로 Spring Boot를 작성 합니다.
