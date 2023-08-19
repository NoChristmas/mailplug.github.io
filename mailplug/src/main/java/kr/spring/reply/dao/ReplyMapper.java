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
