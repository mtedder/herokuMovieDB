/**
 * 
 */
package com.gc.herokudemo.dao;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.hibernate.transform.Transformers;

import com.gc.herokudemo.dto.Category;
import com.gc.herokudemo.dto.Film;

/**
 * @author Maurice
 * Data access object for Heroku Movie database
 */
public class MovieDao {
	/*
	 * Return list of categories from the Category Table
	 */
	public List<Category> getCategories(){		
	    /*
	     * Hibernate stuff
	     */
	      Session session = (new Configuration().configure().buildSessionFactory()).openSession();
	      Transaction tx = null;
	      Category categoryItem = null;
	      List<Category> categoryItemList = new ArrayList<Category>();
	      List<?> categoryListItems = null;
	      try{
	         tx = session.beginTransaction();	         
	         categoryListItems = session.createQuery("FROM Category as a").list();
	         for (Iterator<?> iterator = categoryListItems.iterator(); iterator.hasNext();){
	        	 categoryItem = (Category) iterator.next();	        	
	        	 categoryItemList.add(categoryItem);
	         }
	         tx.commit();
		      }catch (HibernateException e) {
	         if (tx!=null) tx.rollback();
	       //TODO replace with write errors to log file
	         e.printStackTrace();
	      }finally {
	         session.close();
	      }
	      return categoryItemList;
	}
	
	/*
	 * Return list of categories from the Category Table
	 * //SELECT f.title, f.description, f.release_year, f.length, f.rating, f.special_features, cat.name FROM film as f, category as cat, film_category as fcat where f.film_id =  fcat.film_id and cat.category_id = fcat.category_id and cat.name ='Comedy';
	 */
	public List<Film> getFilmsByCategory(String categoryParam){		
	    /*
	     * Hibernate stuff
	     */
	      Session session = (new Configuration().configure().buildSessionFactory()).openSession();
	      Transaction tx = null;	      
	      List<Film> filmListItems = new ArrayList<Film>();	     
	      try{
	         tx = session.beginTransaction();
	         //This is required because the resultset is the result of a join and has not entity mapping
	         Query query = session.createSQLQuery("SELECT f.title, f.description, f.length, cat.name, f.likes, f.dislikes, f.film_id FROM film as f, category as cat, film_category as fcat where f.film_id =  fcat.film_id and cat.category_id = fcat.category_id and cat.name =:film_category")
	        		 .setResultTransformer(Transformers.aliasToBean(Film.class));;

	         query.setString("film_category", categoryParam);
	         filmListItems = query.list();		         	        	       
	         tx.commit();
	    }catch (HibernateException e) {
	        if (tx!=null) tx.rollback();
	      //TODO replace with write errors to log file
	        e.printStackTrace();
	     }finally {
	        session.close();
	     }			         
		return filmListItems;	
	}
	
	/*
	 * Handle like and dislike for films by Id
	 */
	public boolean setFilmLikeDislikeById(boolean like, int id){
	    /*
	     * Hibernate stuff
	     */
	      Session session = (new Configuration().configure().buildSessionFactory()).openSession();
	      Transaction tx = null;
	      Film film = null;
	      try{
	         tx = session.beginTransaction();
	         film = (Film) session.get(Film.class, id);
	         System.out.println("film.getLikes():" + film.getLikes());
	         //I could use an 'update set likes = likes + 1' but that would not demonstrate updating with hibernate
	         if(like){
		         film.setLikes(film.getLikes() + 1);
	         }else{//false indicates increment dislike
	        	 film.setDislikes(film.getDislikes() + 1);
	         }	         
	         session.update(film);
	         tx.commit();
	      }catch (HibernateException e) {
	         if (tx!=null) tx.rollback();
	         //TODO replace with write errors to log file
	         e.printStackTrace();
	      }finally {
	         session.close();
	      }	
	      return true;
	}
}
