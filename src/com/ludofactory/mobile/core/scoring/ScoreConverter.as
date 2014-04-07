/*
LudoFactory
Framework mobile
Author  : Maxime Lhoez
Created : 7 août 2013
*/
package com.ludofactory.mobile.core.scoring
{
	import com.ludofactory.mobile.core.test.push.GameSession;
	import com.ludofactory.mobile.core.authentication.MemberManager;
	import com.ludofactory.mobile.core.storage.Storage;
	import com.ludofactory.mobile.core.storage.StorageConfig;

	public class ScoreConverter
	{
		public function ScoreConverter()
		{
			
		}
		
		/**
		 * Converts the score given in parameter to what the user should
		 * earn depending on which kind of game session it is (whether
		 * a free game or a tournament, and if it is a free or paid game
		 * session).
		 * 
		 * @return 
		 * 
		 * @see com.ludofactory.mobile.push.GameSession
		 * 
		 */		
		public function convertScore(score:int, price:String, type:String):int
		{
			return type == GameSession.TYPE_CLASSIC ? convertFreeGameScore(score, price) : convertTournamentGameScore(score, price);
		}
		
		private function convertFreeGameScore(score:int, price:String):int
		{
			var tabScoreToPoints:Array = (Storage.getInstance().getProperty(StorageConfig.PROPERTY_POINTS_TABLE) as Array).concat();
			for each(var level:ScoreToPointsData in tabScoreToPoints)
			{
				if( score >= level.inf && score <= level.sup)
					return price == GameSession.PRICE_FREE ? (level.pointsWithFree + ((ScoreToPointsData(tabScoreToPoints[tabScoreToPoints.length-1]) == level /* = dernier palier */ && MemberManager.getInstance().getRank() >= 6) ? 10:0)): (MemberManager.getInstance().getRank() < 5 ? level.pointsWithCreditsNormal : level.pointsWithCreditsVip);
			}
			throw new Error("[ScoreConverter] The score " + score + " could not be converted !");
		}
		
		private function convertTournamentGameScore(score:int, price:String):int
		{
			var tabScoreToStars:Array = (Storage.getInstance().getProperty(StorageConfig.PROPERTY_STARS_TABLE) as Array).concat();
			for each(var level:ScoreToStarsData in tabScoreToStars)
			{
				if( score >= level.inf && score <= level.sup)
					return level.stars;
			}
			throw new Error("[ScoreConverter] The score " + score + " could not be converted !");
		}
	}
}