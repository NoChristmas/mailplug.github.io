package kr.spring.reply.vo;

import java.sql.Date;

public class ReplyVO {
	private int reply_num;
	private String user_ip;
	private int board_num;
	private String reply_nickname;
	private String reply_info;
	private Date reply_reg_date;
	
	public int getReply_num() {
		return reply_num;
	}
	public void setReply_num(int reply_num) {
		this.reply_num = reply_num;
	}
	public int getBoard_num() {
		return board_num;
	}
	public void setBoard_num(int board_num) {
		this.board_num = board_num;
	}
	public String getReply_nickname() {
		return reply_nickname;
	}
	public void setReply_nickname(String reply_nickname) {
		this.reply_nickname = reply_nickname;
	}
	public String getReply_info() {
		return reply_info;
	}
	public void setReply_info(String reply_info) {
		this.reply_info = reply_info;
	}
	public Date getReply_reg_date() {
		return reply_reg_date;
	}
	public void setReply_reg_date(Date reply_reg_date) {
		this.reply_reg_date = reply_reg_date;
	}
	public String getUser_ip() {
		return user_ip;
	}
	public void setUser_ip(String user_ip) {
		this.user_ip = user_ip;
	}
	@Override
	public String toString() {
		return "ReplyVO [reply_num=" + reply_num + ", user_ip=" + user_ip + ", board_num=" + board_num
				+ ", reply_nickname=" + reply_nickname + ", reply_info=" + reply_info + ", reply_reg_date="
				+ reply_reg_date + "]";
	}
	
	
	
	
	
}
