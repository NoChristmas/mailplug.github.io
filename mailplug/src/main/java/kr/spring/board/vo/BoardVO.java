package kr.spring.board.vo;

import java.sql.Date;

public class BoardVO {
	private int board_num;
	private String user_ip;
	private String user_nickname;
	private String board_passwd;
	private String board_title;
	private String board_info;
	private int board_hit;
	private Date board_reg_date;

	public int getBoard_num() {
		return board_num;
	}

	public void setBoard_num(int board_num) {
		this.board_num = board_num;
	}

	public String getUser_ip() {
		return user_ip;
	}

	public void setUser_ip(String user_ip) {
		this.user_ip = user_ip;
	}

	public String getBoard_passwd() {
		return board_passwd;
	}

	public void setBoard_passwd(String board_passwd) {
		this.board_passwd = board_passwd;
	}

	public String getBoard_title() {
		return board_title;
	}

	public void setBoard_title(String board_title) {
		this.board_title = board_title;
	}

	public String getBoard_info() {
		return board_info;
	}

	public void setBoard_info(String board_info) {
		this.board_info = board_info;
	}

	public int getBoard_hit() {
		return board_hit;
	}

	public void setBoard_hit(int board_hit) {
		this.board_hit = board_hit;
	}

	public String getUser_nickname() {
		return user_nickname;
	}

	public void setUser_nickname(String user_nickname) {
		this.user_nickname = user_nickname;
	}

	public Date getBoard_reg_date() {
		return board_reg_date;
	}

	public void setBoard_reg_date(Date board_reg_date) {
		this.board_reg_date = board_reg_date;
	}

	@Override
	public String toString() {
		return "BoardVO [board_num=" + board_num + ", user_ip=" + user_ip + ", user_nickname=" + user_nickname
				+ ", board_passwd=" + board_passwd + ", board_title=" + board_title + ", board_info=" + board_info
				+ ", board_hit=" + board_hit + ", board_reg_date=" + board_reg_date + "]";
	}

}
