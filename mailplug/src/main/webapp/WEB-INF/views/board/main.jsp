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
<style>
		body {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		margin: 0;
	}

	table {
		width: 80%;
		border-collapse: collapse;
		margin: 20px auto;
	}

	th, td {
		
		border: 1px solid #ccc;
		padding: 10px;
		width:150px;
		min-width:150px;
		text-align: center;
	}

	.paging-box {
		display: flex;
		justify-content: center;
		align-items: center;
		margin-top: 20px;
	}

	.paging-btn {
		display: flex;
		align-items: center;
		font-size: 20px;
		list-style: none;
		padding: 0;
	}

	.paging-btn li {
		margin: 0 5px;
		padding: 5px 10px;
		border: 1px solid #ccc;
		border-radius: 5px;
		cursor: pointer;
		transition: background-color 0.3s;
	}

	.paging-btn li:hover {
		background-color: #f0f0f0;
	}

	a {
		background-color: #007bff;
    	transition: background-color 0.3s;
    	text-decoration: none;
        color: inherit;
    	display: inline-block;
    	margin-top: 10px;
   		padding: 6px 12px;
    	border: 1px solid #ddd;
    	border-radius: 5px;
    	background-color: #f5f5f5;
    	font-size: 14px;
    	cursor: pointer;
	}

	a:hover {
		background-color: #ddd;
	}
</style>
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