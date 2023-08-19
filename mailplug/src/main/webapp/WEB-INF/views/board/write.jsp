<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core"  prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>mailplug | 글쓰기</title>
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

<style type="text/css">
	.main-box {
		width: 100%;
		max-width: 800px;
		margin: 0 auto;
		padding: 20px;
		box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
		border-radius: 10px;
		background-color: #f8f9fa;
	}

	#form-submit {
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	label {
		margin-top: 20px;
		font-weight: bold;
	}

	input, textarea {
		width: 100%;
		padding: 10px;
		border: 1px solid #ced4da;
		border-radius: 5px;
		margin-top: 5px;
		font-size: 16px;
		background-color: #ffffff;
	}

	textarea {
		height: 150px;
		resize: vertical;
	}

	button {
		margin-top: 20px;
		padding: 10px 20px;
		border: none;
		border-radius: 5px;
		background-color: #007bff;
		color: #ffffff;
		font-size: 16px;
		cursor: pointer;
		transition: background-color 0.3s;
	}

	button:hover {
		background-color: #0056b3;
	}
</style>
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