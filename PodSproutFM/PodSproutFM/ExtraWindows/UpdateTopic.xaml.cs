using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для UpdateTopic.xaml
    /// </summary>
    public partial class UpdateTopic : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        Int16 topicId;
        string narratorNameYear, oldTopicName, newTopicName;

        public UpdateTopic()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        public UpdateTopic(Int16 id, string narrator, string old)
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            this.topicId = id;
            this.narratorNameYear = narrator;
            this.oldTopicName = old;

            narratorName.Text = narrator;
            thisTopicName.Text = old;
        }

        private void TopicPreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("[^0-9]+");
            e.Handled = regex.IsMatch(e.Text);
        }

        private void AddBtn_Click(object sender, RoutedEventArgs e)
        {
            string yearPattern = @"^(1989|199[0-9]|20[0-2][0-9]|202[0-4])$";
            Regex yearRegex = new Regex(yearPattern);
            if (String.IsNullOrWhiteSpace(topicName.Text.Trim()) && String.IsNullOrWhiteSpace(topicYear.Text.Trim()))
            {
                MessageBox.Show("Заполните хотя бы одно из полей!");
                return;
            }
            if (!String.IsNullOrWhiteSpace(topicName.Text.Trim()))
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.UPDATETOPICNAME";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PTOPICID", OracleDbType.Int16, 10).Value = topicId;
                cmd.Parameters.Add("PNEWNAME", OracleDbType.Varchar2, 30).Value = topicName.Text.Trim();
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Название альбома успешно обновлено!");
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Это название альбома уже существует!");
                }
                con.Close();
            }
            if (!String.IsNullOrWhiteSpace(topicYear.Text.Trim()))
            {
                if (!yearRegex.IsMatch(topicYear.Text.Trim()))
                {
                    MessageBox.Show("Год должен быть в диапазоне от 1989 до текущего года!");
                    return;
                }
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.UPDATETOPICYEAR";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PTOPICID", OracleDbType.Int16, 10).Value = topicId;
                cmd.Parameters.Add("PNEWYEAR", OracleDbType.Int16, 10).Value = Convert.ToInt16(topicYear.Text.Trim());
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Год выпуска альбома успешно обновлен!");
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Это название альбома уже существует!");
                }
                con.Close();
            }
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnMinimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }
    }
}