from datetime import datetime, timedelta
import math

class SleepDebtSimulator:
    TARGET_SLEEP = 7.0
    RECOMMENDED_SLEEP = 8.0
    MAX_DAILY_DEBT = 16.0
    MAX_TOTAL_DEBT = 40.0
    RECOVERY_RATE = 0.4
    LOOKBACK_DAYS = 10  # Consider last 10 days for debt calculation

    def __init__(self):
        self.current_debt = 0.0
        self.weekly_averages = []

    def calculate_window_debt(self, window_data):
        """Calculate debt for a specific window of days"""
        total_debt = 0.0
        
        # Process days in chronological order
        for day in sorted(window_data.keys()):
            hours = window_data[day]
            daily_difference = self.TARGET_SLEEP - hours

            if daily_difference > 0:
                # Add debt
                new_debt = min(daily_difference, self.MAX_DAILY_DEBT)
                total_debt += new_debt
            else:
                # Apply recovery
                recovery_hours = abs(daily_difference) * self.RECOVERY_RATE
                total_debt = max(0, total_debt - recovery_hours)
        
        return min(total_debt, self.MAX_TOTAL_DEBT)

    def calculate_debt(self, sleep_data):
        """
        Calculate sleep debt from a dictionary of {date: hours_slept}
        using a sliding window of the last 10 days
        """
        self.current_debt = 0.0
        self.weekly_averages = []

        if not sleep_data:
            return

        # Sort days chronologically
        sorted_days = sorted(sleep_data.keys())
        
        # Get the last LOOKBACK_DAYS days
        window_days = sorted_days[-self.LOOKBACK_DAYS:] if len(sorted_days) >= self.LOOKBACK_DAYS else sorted_days
        window_data = {day: sleep_data[day] for day in window_days}
        
        # Calculate debt for the window
        self.current_debt = self.calculate_window_debt(window_data)

        # Calculate weekly averages from the available data
        if len(sorted_days) >= 14:  # Need at least 2 weeks for trend
            # Current week
            current_week = sorted_days[-7:]
            current_avg = sum(sleep_data[d] for d in current_week) / 7
            
            # Previous week
            prev_week = sorted_days[-14:-7]
            prev_avg = sum(sleep_data[d] for d in prev_week) / 7
            
            self.weekly_averages = [prev_avg, current_avg]

    def get_stats(self, sleep_data):
        """
        Get comprehensive sleep statistics
        """
        if not sleep_data:
            return {
                'average_sleep': 0.0,
                'min_sleep': 0.0,
                'max_sleep': 0.0,
                'current_debt': 0.0,
                'trend': 'No data',
                'recovery_days': 0
            }

        self.calculate_debt(sleep_data)
        sleep_hours = list(sleep_data.values())

        return {
            'average_sleep': sum(sleep_hours) / len(sleep_hours),
            'min_sleep': min(sleep_hours),
            'max_sleep': max(sleep_hours),
            'current_debt': self.current_debt,
            'trend': self.get_trend(),
            'recovery_days': self.get_recovery_estimate()
        }

    def get_trend(self):
        if len(self.weekly_averages) < 2:
            return 'Insufficient data'
        
        current = self.weekly_averages[-1]
        previous = self.weekly_averages[-2]
        
        if current > previous:
            return 'Improving'
        elif current < previous:
            return 'Declining'
        return 'Stable'

    def get_recovery_estimate(self):
        if self.current_debt == 0:
            return 0
        
        extra_sleep_per_day = 1.0
        recovery_per_day = extra_sleep_per_day * self.RECOVERY_RATE
        return math.ceil(self.current_debt / recovery_per_day)

def run_simulation(days=14):
    simulator = SleepDebtSimulator()
    
    # Generate sample sleep data
    today = datetime.now().date()
    sleep_data = {}
    
    # Scenario 1: Consistent undersleep
    for i in range(days):
        date = today - timedelta(days=i)
        sleep_data[date] = 6.0  # Consistently sleeping 6 hours
    
    stats = simulator.get_stats(sleep_data)
    print("\nScenario 1 - Consistent undersleep (6h):")
    print(f"Current Debt: {stats['current_debt']:.2f}h")
    print(f"Recovery Days: {stats['recovery_days']}")

    # Scenario 2: Variable sleep pattern
    sleep_data = {}
    pattern = [8.0, 7.0, 6.0, 6.5, 8.5, 5.0, 7.0]  # Weekly pattern
    for i in range(days):
        date = today - timedelta(days=i)
        sleep_data[date] = pattern[i % 7]
    
    stats = simulator.get_stats(sleep_data)
    print("\nScenario 2 - Variable sleep pattern:")
    print(f"Current Debt: {stats['current_debt']:.2f}h")
    print(f"Recovery Days: {stats['recovery_days']}")

if __name__ == "__main__":
    run_simulation()
