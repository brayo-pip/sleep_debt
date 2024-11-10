import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
from datetime import datetime, timedelta
from algo import SleepDebtSimulator
import os
import numpy as np
from numpy.random import normal, choice
from collections import deque

# Set seaborn style
sns.set_theme(style="darkgrid")
sns.set_palette("husl")

class WeightedSleepDebtSimulator(SleepDebtSimulator):
    DECAY_FACTOR = 1  # No decay by default (matches regular debt)
    LOOKBACK_DAYS = [7, 10, 14]
    SMOOTHING_FACTOR = 0.1  # EMA smoothing factor (higher = more smoothing)
    
    def __init__(self):
        super().__init__()
        self.smoothed_debt = 0.0
    
    def calculate_window_debt(self, window_data):
        """Calculate debt for a specific window of days"""
        total_debt = 0.0
        
        # Convert to list and sort to ensure chronological order
        days = sorted(window_data.keys())
        
        for i, day in enumerate(days):
            hours = window_data[day]
            daily_difference = self.TARGET_SLEEP - hours
            days_from_end = len(days) - 1 - i

            if daily_difference > 0:
                # Calculate debt
                daily_debt = min(daily_difference, self.MAX_DAILY_DEBT)
                # Apply decay based on distance from most recent day
                if self.DECAY_FACTOR < 1:
                    daily_debt *= pow(self.DECAY_FACTOR, days_from_end)
                total_debt += daily_debt
            else:
                # Calculate recovery (no decay applied)
                recovery_hours = abs(daily_difference) * self.RECOVERY_RATE
                total_debt = max(0, total_debt - recovery_hours)
        
        raw_debt = min(total_debt, self.MAX_TOTAL_DEBT)
        
        # Apply EMA smoothing
        self.smoothed_debt = (raw_debt * (1 - self.SMOOTHING_FACTOR) + 
                            self.smoothed_debt * self.SMOOTHING_FACTOR)
        
        return self.smoothed_debt
    
    def calculate_debt(self, sleep_data):
        """
        Calculate sleep debt using a sliding window of the last 10 days.
        When DECAY_FACTOR = 1, behaves exactly like regular debt calculator.
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

        # Calculate weekly average if we have enough data
        if len(sorted_days) >= 7:
            last_week = sorted_days[-7:]
            week_hours = [sleep_data[day] for day in last_week]
            self.weekly_averages.append(sum(week_hours) / 7)


        # Calculate weighted weekly average if we have enough data
        if len(sorted_days) >= 7:
            last_week = sorted_days[-7:]
            week_hours = []
            week_weights = []
            
            for i, day in enumerate(last_week):
                weight = pow(self.DECAY_FACTOR, 6 - i)  # Most recent day has highest weight
                week_hours.append(sleep_data[day] * weight)
                week_weights.append(weight)
            
            weighted_avg = sum(week_hours) / sum(week_weights)
            self.weekly_averages.append(weighted_avg)

def plot_comparison(sleep_data, regular_debt, weighted_debt, title):
    dates = sorted(sleep_data.keys())
    sleep_hours = [sleep_data[d] for d in dates]
    
    # Create figure with seaborn style
    fig = plt.figure(figsize=(14, 10))
    gs = fig.add_gridspec(3, 1, height_ratios=[2, 2, 1])
    ax1 = fig.add_subplot(gs[0])
    ax2 = fig.add_subplot(gs[1])
    ax3 = fig.add_subplot(gs[2])
    
    fig.suptitle(title, fontsize=14, y=0.95)
    
    # Plot sleep hours with enhanced styling
    sns.lineplot(x=dates, y=sleep_hours, ax=ax1, label='Sleep Hours', linewidth=2)
    ax1.axhline(y=7, color='red', linestyle='--', label='Target (7h)', alpha=0.7)
    ax1.axhline(y=8, color='green', linestyle='--', label='Recommended (8h)', alpha=0.7)
    ax1.set_ylabel('Hours of Sleep', fontsize=10)
    ax1.set_xlabel('')
    ax1.legend(fontsize=9, loc='upper right')
    ax1.grid(True, alpha=0.3)
    
    # Format dates on x-axis
    ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
    ax1.xaxis.set_major_locator(mdates.MonthLocator())  # Show one label per month
    
    # Plot debt comparison with enhanced styling
    sns.lineplot(x=dates, y=regular_debt, ax=ax2, label='Regular Debt', linewidth=2)
    sns.lineplot(x=dates, y=weighted_debt, ax=ax2, label='Weighted Debt', linewidth=2)
    ax2.set_ylabel('Debt Hours', fontsize=10)
    ax2.set_xlabel('')
    ax2.legend(fontsize=9, loc='upper right')
    ax2.grid(True, alpha=0.3)
    
    # Format dates on x-axis
    ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
    ax2.xaxis.set_major_locator(mdates.MonthLocator())  # Show one label per month
    
    # Add summary statistics
    ax3.axis('off')
    summary_text = (
        f"Summary Statistics:\n"
        f"Average Sleep: {sum(sleep_hours)/len(sleep_hours):.2f}h\n"
        f"Min Sleep: {min(sleep_hours):.1f}h | Max Sleep: {max(sleep_hours):.1f}h\n"
        f"Final Regular Debt: {regular_debt[-1]:.2f}h | Final Weighted Debt: {weighted_debt[-1]:.2f}h\n"
        f"Debt Difference: {abs(regular_debt[-1] - weighted_debt[-1]):.2f}h"
    )
    ax3.text(0.5, 0.5, summary_text, 
             horizontalalignment='center',
             verticalalignment='center',
             fontsize=10,
             bbox=dict(facecolor='white', alpha=0.8, edgecolor='none'))
    
    # Rotate x-axis labels for better readability
    for ax in [ax1, ax2]:
        plt.setp(ax.get_xticklabels(), rotation=45, ha='right')
    
    plt.tight_layout()
    return fig

def run_comparison(pattern_name, sleep_pattern, days=14):
    regular_simulator = SleepDebtSimulator()
    weighted_simulator = WeightedSleepDebtSimulator()
    
    regular_debt_values = []
    weighted_debt_values = []
    
    # Check if sleep_pattern is a dictionary (yearly data) or a pattern
    if isinstance(sleep_pattern, dict):
        sleep_data = sleep_pattern
        dates = sorted(sleep_data.keys())
    else:
        # Generate sleep data from pattern
        today = datetime.now().date()
        sleep_data = {}
        dates = []
        for i in range(days):
            date = today - timedelta(days=days-1-i)
            dates.append(date)
            if callable(sleep_pattern):
                sleep_data[date] = sleep_pattern(i)
            else:
                sleep_data[date] = sleep_pattern[i % len(sleep_pattern)]
    
    # Calculate debt progression
    for date in dates:
        current_data = {d: sleep_data[d] for d in sleep_data if d <= date}
        regular_simulator.calculate_debt(current_data)
        weighted_simulator.calculate_debt(current_data)
        
        regular_debt_values.append(regular_simulator.current_debt)
        weighted_debt_values.append(weighted_simulator.current_debt)
    
    # Get final stats
    regular_stats = regular_simulator.get_stats(sleep_data)
    weighted_stats = weighted_simulator.get_stats(sleep_data)
    
    # Plot comparison
    fig = plot_comparison(sleep_data, regular_debt_values, weighted_debt_values, 
                         f"Sleep Pattern: {pattern_name} (Regular vs Weighted)")
    
    print(f"\nScenario - {pattern_name}:")
    print("Regular calculation:")
    print(f"Final Debt: {regular_stats['current_debt']:.2f}h")
    print(f"Recovery Days: {regular_stats['recovery_days']}")
    print(f"Average Sleep: {regular_stats['average_sleep']:.2f}h")
    print(f"Trend: {regular_stats['trend']}")
    
    print("\nWeighted calculation (decay=0.95):")
    print(f"Final Debt: {weighted_stats['current_debt']:.2f}h")
    print(f"Recovery Days: {weighted_stats['recovery_days']}")
    print(f"Average Sleep: {weighted_stats['average_sleep']:.2f}h")
    print(f"Trend: {weighted_stats['trend']}")
    
    return fig, (regular_stats, weighted_stats)

import numpy as np
from numpy.random import normal, choice

def generate_yearly_sleep_data():
    """Generate a year's worth of realistic sleep data with patterns."""
    today = datetime.now().date()
    start_date = today - timedelta(days=365)
    dates = [start_date + timedelta(days=i) for i in range(366)]  # Include leap year possibility
    sleep_data = {}
    
    # Base patterns
    weekday_base = 7.0  # Target average for weekdays
    weekend_base = 8.0  # Target average for weekends
    
    # Seasonal variation (less sleep in summer, more in winter)
    seasonal_variation = np.sin(np.linspace(0, 2*np.pi, 366)) * 0.5
    
    # Generate data for each day
    for i, date in enumerate(dates):
        is_weekend = date.weekday() >= 5
        base = weekend_base if is_weekend else weekday_base
        
        # Add various factors:
        seasonal = seasonal_variation[i]
        daily_variation = normal(0, 0.5)  # Random daily variation
        
        # Special cases
        is_special_case = choice([True, False], p=[0.1, 0.9])  # 10% chance of special case
        special_case = 0
        if is_special_case:
            special_case = choice([-2, 2], p=[0.7, 0.3])  # More likely to undersleep
        
        # Calculate final sleep hours with constraints
        sleep_hours = base + seasonal + daily_variation + special_case
        sleep_hours = max(3, min(12, sleep_hours))  # Constrain between 3 and 12 hours
        sleep_hours = round(sleep_hours, 2)
        
        sleep_data[date] = sleep_hours
    
    return sleep_data

def generate_monthly_data():
    """Generate a month of sleep data using the same patterns as yearly data"""
    today = datetime.now().date()
    start_date = today - timedelta(days=30)
    dates = [start_date + timedelta(days=i) for i in range(31)]
    sleep_data = {}
    
    # Base patterns (same as yearly)
    weekday_base = 7.0
    weekend_base = 8.0
    
    # Seasonal variation (sample from current month's position in year)
    day_of_year = dates[0].timetuple().tm_yday
    seasonal_phase = (day_of_year / 366) * 2 * np.pi
    seasonal_base = np.sin(seasonal_phase) * 0.5
    
    # Generate data for each day
    for date in dates:
        is_weekend = date.weekday() >= 5
        base = weekend_base if is_weekend else weekday_base
        
        # Add various factors
        daily_variation = normal(0, 0.5)  # Random daily variation
        
        # Special cases (same probability as yearly)
        is_special_case = choice([True, False], p=[0.1, 0.9])
        special_case = 0
        if is_special_case:
            special_case = choice([-2, 2], p=[0.7, 0.3])
        
        # Calculate final sleep hours
        sleep_hours = base + seasonal_base + daily_variation + special_case
        sleep_hours = max(3, min(12, sleep_hours))  # Constrain between 3 and 12 hours
        sleep_data[date] = round(sleep_hours, 2)
    
    return sleep_data

def main():
    # Create plots directory if it doesn't exist
    plots_dir = "sleep_plots"
    if not os.path.exists(plots_dir):
        os.makedirs(plots_dir)
    
    # Fixed parameters
    WeightedSleepDebtSimulator.DECAY_FACTOR = 0.9
    WeightedSleepDebtSimulator.LOOKBACK_DAYS = 10
    SleepDebtSimulator.LOOKBACK_DAYS = 10

    # Run yearly analysis
    print("\n=== Yearly Analysis ===")
    yearly_data = generate_yearly_sleep_data()
    
    fig, stats = run_comparison("Yearly Pattern", yearly_data)
    save_path = os.path.join(plots_dir, "yearly.png")
    fig.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close(fig)
    
    print_sleep_statistics("Yearly", yearly_data)
    
    # Run monthly analysis
    print("\n=== Monthly Analysis ===")
    monthly_data = generate_monthly_data()
    
    fig, stats = run_comparison("Monthly Pattern", monthly_data)
    save_path = os.path.join(plots_dir, "monthly.png")
    fig.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.close(fig)
    
    print_sleep_statistics("Monthly", monthly_data)

def print_sleep_statistics(period, sleep_data):
    """Print sleep statistics for the given period and data"""
    sleep_hours = list(sleep_data.values())
    weekday_sleep = [h for d, h in sleep_data.items() if d.weekday() < 5]
    weekend_sleep = [h for d, h in sleep_data.items() if d.weekday() >= 5]
    
    print(f"\n{period} Sleep Statistics:")
    print(f"Average Sleep: {np.mean(sleep_hours):.2f}h")
    print(f"Weekday Average: {np.mean(weekday_sleep):.2f}h")
    print(f"Weekend Average: {np.mean(weekend_sleep):.2f}h")
    print(f"Standard Deviation: {np.std(sleep_hours):.2f}h")
    print(f"Minimum Sleep: {min(sleep_hours):.2f}h")
    print(f"Maximum Sleep: {max(sleep_hours):.2f}h")

if __name__ == "__main__":
    main()
