<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상세 페이지</title>
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
<style>
	.main-box {
        width: 100%;
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
        background-color: #f8f9fa;
    }

    .detail-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
        font-size: 14px;
    }

    .detail-header-item {
        flex: 1;
    }

    .detail-title {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 10px;
    }

    .detail-content {
        font-size: 16px;
        margin-bottom: 20px;
        white-space: pre-line;
    }

    .detail-options {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 14px;
        color: #666;
    }

    .option-divider {
        margin: 0 10px;
    }

    .reply {
        margin-top: 20px;
        padding: 10px;
        background-color: #ffffff;
        border-radius: 5px;
        box-shadow: 0px 0px 5px rgba(0, 0, 0, 0.1);
    }

    .reply-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 12px;
        color: #666;
        margin-bottom: 5px;
    }

    .reply-header-item {
        flex: 1;
    }

    .reply-content {
        font-size: 14px;
        margin-bottom: 10px;
    }

    .reply-options {
        display: flex;
        justify-content: flex-end;
        align-items: center;
    }

    .reply-action, .delete-reply {
        border: 1px solid #ddd;
        border-radius: 5px;
        padding: 2px 5px;
        cursor: pointer;
    }

    .virtual-form {
        margin-top: 10px;
    }

    .reply-form {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        background-color: #f5f5f5;
    }

    .reply-form label {
        font-size: 12px;
        margin-top: 5px;
    }

    .reply-form input, .reply-form textarea {
        width: 100%;
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 5px;
        margin-top: 5px;
    }

    .reply-form button {
        margin-top: 10px;
        padding: 6px 12px;
        border: none;
        border-radius: 5px;
        background-color: #007bff;
        color: #ffffff;
        font-size: 14px;
        cursor: pointer;
        transition: background-color 0.3s;
    }

    .reply-form button:hover {
        background-color: #0056b3;
    }

    #deleteBoard {
        display: inline-block;
        margin-top: 10px;
        padding: 6px 12px;
        border: 1px solid #ddd;
        border-radius: 5px;
        background-color: #f5f5f5;
        font-size: 14px;
        cursor: pointer;
    }

    #deleteBoard:hover {
        background-color: #ddd;
    }
    
    #form-submit {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-top: 20px;
    }

    #form-submit label {
        font-weight: bold;
        margin-right: 20px;
        margin-left:20px;
    }

    #form-submit input {
    	width:150px;
    	height:50px;
    	border-radius:10px;
    	
    }
    #form-submit textarea {
        width: 500px;
        height:40px;
        min-height:40px;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 10px;
        
    }

    #form-submit button {
        padding: 10px 20px;
        border: none;
        border-radius: 10px;
        background-color: #007bff;
        color: #ffffff;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.3s;
        margin-left:50px;
    }

    #form-submit button:hover {
        background-color: #0056b3;
    }
    
    a, span {
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
    
    a:hover, span:hover {
    	background-color: #ddd;
    }
</style>
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