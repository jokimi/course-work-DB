using Oracle.ManagedDataAccess.Client;
using PodSproutFM.UserControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PodSproutFM
{
    /// <summary>
    /// Логика взаимодействия для AdminWindow.xaml
    /// </summary>
    public partial class AdminWindow : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SPROUT;PASSWORD=sprout";
        int rowMargin = 20, rowCounter = 0, rowCounterSearch = 0;
        string searchLineBuffer;

        public AdminWindow()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
        }

        public void Load20Users()
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SELECT * FROM (select user_id, user_login, decr, role_name, row_number() over (order by user_login) rn from SYS.user_role_full_view) where rn between :n and :m ORDER BY user_login ASC";
            cmd.Parameters.Add(new OracleParameter("n", rowCounter));
            cmd.Parameters.Add(new OracleParameter("m", rowCounter + rowMargin));
            rowCounter += rowMargin;
            rowCounter++;
            cmd.CommandType = CommandType.Text;
            OracleDataReader reader = cmd.ExecuteReader();
            userList.Children.Clear();
            while (reader.Read())
            {
                UserUC us = new UserUC(reader.GetInt32(0), reader.GetString(1), reader.GetString(2), reader.GetString(3));
                userList.Children.Add(us);
            }
            con.Close();
        }

        public void Search20Users()
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            if (searchBarUser.Text.Trim().ToUpper() != searchLineBuffer)
            {
                rowCounterSearch = 0;
            }
            searchLineBuffer = searchBarUser.Text.Trim().ToUpper();
            cmd.CommandText = "SELECT * FROM (select user_id, user_login, decr, role_name, row_number() over (order by user_login) rn from SYS.user_role_full_view) where upper(user_login) LIKE '%' || :search || '%' AND rn between :n and :m  ORDER BY user_login ASC";
            cmd.Parameters.Add(new OracleParameter("search", searchLineBuffer));
            cmd.Parameters.Add(new OracleParameter("n", rowCounterSearch));
            cmd.Parameters.Add(new OracleParameter("m", rowCounterSearch + rowMargin));
            rowCounterSearch += rowMargin;
            rowCounterSearch++;
            cmd.CommandType = CommandType.Text;
            OracleDataReader reader = cmd.ExecuteReader();
            userList.Children.Clear();
            while (reader.Read())
            {
                UserUC us = new UserUC(reader.GetInt32(0), reader.GetString(1), reader.GetString(2), reader.GetString(3));
                userList.Children.Add(us);
            }
            con.Close();
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

        private void SearchButtonUser_Click(object sender, RoutedEventArgs e)
        {
            Search20Users();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            Load20Users();
        }

        private void XMLExportButton_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.USEREXPORT";
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                cmd.ExecuteNonQuery();
                xmlExportButton.IsEnabled = false;
                xmlImportButton.IsEnabled = true;
            }
            catch (Exception exc)
            {
                MessageBox.Show("Ошибка экспорта!");
            }
            con.Close();
        }

        private void XMLExportButton2_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.PODCASTEXPORT";
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                cmd.ExecuteNonQuery();
                xmlExportButton2.IsEnabled = false;
                xmlImportButton.IsEnabled = true;
            }
            catch (Exception exc)
            {
                MessageBox.Show("Ошибка экспорта!");
            }
            con.Close();
        }

        private void XMLImportButton_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.NARRATORIMPORT";
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                cmd.ExecuteNonQuery();
                xmlExportButton.IsEnabled = true;
                xmlExportButton2.IsEnabled = true;
                xmlImportButton.IsEnabled = false;
            }
            catch (Exception exc)
            {
                MessageBox.Show("Ошибка импорта!");
            }
            con.Close();
        }

        private void InsertUsersButton_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.INSERT100KUSERS";
            cmd.CommandType = CommandType.StoredProcedure;
            try
            {
                cmd.ExecuteNonQuery();
                insertUsersButton.IsEnabled = false;
                MessageBox.Show("Пользователи успешно добавлены!");
            }
            catch (Exception exc)
            {
                MessageBox.Show("Ошибка добавления пользователей: " + exc.Message);
            }
            con.Close();
        }

        private void DeleteUsersButton_Click(object sender, RoutedEventArgs e)
        {
            con.Open();
            using (OracleCommand cmd = con.CreateCommand())
            {
                cmd.CommandText = "SYS.DELETE100KUSERS";
                cmd.CommandType = CommandType.StoredProcedure;
                try
                {
                    cmd.ExecuteNonQuery();
                    insertUsersButton.IsEnabled = true;
                    MessageBox.Show("Пользователи удалены!");
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Ошибка удаления пользователей: " + exc.Message);
                }
                finally
                {
                    con.Close();
                }
            }
        }

        private void ShowNext20_Click(object sender, RoutedEventArgs e)
        {
            Load20Users();
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }
    }
}