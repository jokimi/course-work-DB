using Oracle.ManagedDataAccess.Client;
using PodSproutFM.ExtraWindows;
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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PodSproutFM
{
    /// <summary>
    /// Логика взаимодействия для Home.xaml
    /// </summary>
    public partial class Home : Page
    {
        OracleConnection con = new OracleConnection();
        public Home()
        {
            InitializeComponent();
            con.ConnectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";
        }

        public void OnTopicAdded()
        {
            LoadTopics();
        }

        public void OnNarratorAdded()
        {
            LoadNarrators();
        }

        public void OnNarratorUpdated()
        {
            LoadNarrators();
        }

        public void OnPodcastAdded()
        {
            LoadPodcasts();
        }

        public void SettingsDataFill()
        {
            con.Open();
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.SEARCHUSER";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PUSERLOGIN", OracleDbType.Varchar2, 30).Value = DataWorker.CurrentUserLogin;
            cmd.Parameters.Add("OUSERLOGIN", OracleDbType.Varchar2, 30);
            cmd.Parameters["OUSERLOGIN"].Direction = ParameterDirection.Output;
            cmd.Parameters.Add("OUSERPASSWORD", OracleDbType.Varchar2, 30);
            cmd.Parameters["OUSERPASSWORD"].Direction = ParameterDirection.Output;
            try
            {
                cmd.ExecuteNonQuery();
                settingUserLogin.Text = Convert.ToString(cmd.Parameters["OUSERLOGIN"].Value);
                settingUserPassword.Text = Convert.ToString(cmd.Parameters["OUSERPASSWORD"].Value);
            }
            catch (Exception exc)
            {
                MessageBox.Show("Пользователь не найден!");
            }
            con.Close();
        }

        public void LoadNarrators()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHNARRATOR";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string pname = "";
                    cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = pname;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        narratorList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            NarratorUC narrator = new NarratorUC(reader.GetInt16(0), reader.GetString(1));
                            narratorList.Children.Add(narrator);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет дикторов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке дикторов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        public void LoadTopics()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHTOPIC";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string pname = "";
                    cmd.Parameters.Add("PTOPICNAME", OracleDbType.Varchar2, 30).Value = pname;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        topicList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            TopicUC topic = new TopicUC(reader.GetInt16(0), reader.GetString(2), reader.GetString(1), reader.GetInt16(3));
                            topicList.Children.Add(topic);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет тем для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке тем: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        public void LoadPodcasts()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCAST";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string pname = "";
                    cmd.Parameters.Add("PPODCASTNAME", OracleDbType.Varchar2, 30).Value = pname;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        podcastList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            PodcastUC podcast = new PodcastUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            podcastList.Children.Add(podcast);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет подкастов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        public void LoadPlaylist()
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCASTBYPLAYLIST";
                    cmd.CommandType = CommandType.StoredProcedure;
                    string pname = "";
                    cmd.Parameters.Add("PPODCASTNAME", OracleDbType.Varchar2, 30).Value = pname;
                    cmd.Parameters.Add("PUSERID", OracleDbType.Int32, 10).Value = DataWorker.CurrentUserId;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        playlistList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            SavedUC podcast = new SavedUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            playlistList.Children.Add(podcast);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void BackSettingClick(object sender, RoutedEventArgs e)
        {
            this.NavigationService.Navigate(new Uri("Login.xaml", UriKind.Relative));
        }

        private void ChangeLoginClick(object sender, RoutedEventArgs e)
        {
            settingUserLogin.IsReadOnly = false;
            settingChangeLoginButton.IsEnabled = false;
            settingUpdateLoginButton.IsEnabled = true;
            settingCancelLoginButton.IsEnabled = true;
        }

        private void UpdateLoginClick(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Вы уверены, что хотите изменить логин?", "Изменение логина", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.UPDATEUSERLOGIN";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PUSERLOGIN", OracleDbType.Varchar2, 30).Value = DataWorker.CurrentUserLogin;
                cmd.Parameters.Add("PNEWUSERLOGIN", OracleDbType.Varchar2, 30).Value = settingUserLogin.Text.Trim();
                try
                {
                    cmd.ExecuteNonQuery();
                    DataWorker.CurrentUserLogin = settingUserLogin.Text.Trim();
                    settingUserLogin.IsReadOnly = true;
                    settingChangeLoginButton.IsEnabled = true;
                    settingUpdateLoginButton.IsEnabled = false;
                    settingCancelLoginButton.IsEnabled = false;
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Этот логин уже занят!");
                }
                con.Close();
            }
            else
            {
                SettingsDataFill();
            }
        }

        private void CancelLoginClick(object sender, RoutedEventArgs e)
        {
            settingUserLogin.IsReadOnly = true;
            settingChangeLoginButton.IsEnabled = true;
            settingUpdateLoginButton.IsEnabled = false;
            settingCancelLoginButton.IsEnabled = false;
            SettingsDataFill();
        }

        private void ChangePasswordClick(object sender, RoutedEventArgs e)
        {
            settingUserPassword.IsReadOnly = false;
            settingChangePasswordButton.IsEnabled = false;
            settingUpdatePasswordButton.IsEnabled = true;
            settingCancelPasswordButton.IsEnabled = true;
        }

        private void UpdatePasswordClick(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Вы уверены, что хотите изменить пароль?", "Изменение пароля", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.UPDATEUSERPASSWORD";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PUSERLOGIN", OracleDbType.Varchar2, 30).Value = DataWorker.CurrentUserLogin;
                cmd.Parameters.Add("PNEWUSERPASSWORD", OracleDbType.Varchar2, 30).Value = settingUserPassword.Text.Trim();
                try
                {
                    cmd.ExecuteNonQuery();
                    settingUserPassword.IsReadOnly = true;
                    settingChangePasswordButton.IsEnabled = true;
                    settingUpdatePasswordButton.IsEnabled = false;
                    settingCancelPasswordButton.IsEnabled = false;
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Пользователь не найден!");
                }
                con.Close();
            }
            else
            {
                SettingsDataFill();
            }
        }

        private void CancelPasswordClick(object sender, RoutedEventArgs e)
        {
            settingUserPassword.IsReadOnly = true;
            settingChangePasswordButton.IsEnabled = true;
            settingUpdatePasswordButton.IsEnabled = false;
            settingCancelPasswordButton.IsEnabled = false;
            SettingsDataFill();
        }

        private void DeleteUserClick(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Вы уверены, что хотите удалить этот аккаунт?", "Удаление пользователя", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.DELETEUSER";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PLOGIN", OracleDbType.Varchar2, 30).Value = DataWorker.CurrentUserLogin;
                try
                {
                    cmd.ExecuteNonQuery();
                    DataWorker.CurrentUserLogin = settingUserLogin.Text.Trim();
                    this.NavigationService.Navigate(new Uri("Login.xaml", UriKind.Relative));
                }
                catch (Exception exc)
                {
                    MessageBox.Show("Этот логин уже занят!");
                }
                con.Close();
            }
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            LoadTopics();
            LoadNarrators();
            LoadPodcasts();
            LoadPlaylist();
            SettingsDataFill();
            if (DataWorker.CurrentUserRole == "ADMIN")
            {
                deleteUserButton.IsEnabled = false;
                tableControlButton.Visibility = Visibility.Visible;
                addNewNarratorButton.Visibility = Visibility.Visible;
                addNewTopicButton.Visibility = Visibility.Visible;
                addNewPodcastButton.Visibility = Visibility.Visible;
            }
        }

        private void AddNewNarratorButton_Click(object sender, RoutedEventArgs e)
        {
            AddNewNarrator addNarratorWin = new AddNewNarrator();
            addNarratorWin.NarratorAdded += OnNarratorAdded;
            addNarratorWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void AddNewTopicButton_Click(object sender, RoutedEventArgs e)
        {
            AddNewTopic addTopicWin = new AddNewTopic();
            addTopicWin.TopicAdded += OnTopicAdded;
            addTopicWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void SearchButtonNarrators_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHNARRATOR";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = searchBarNarrator.Text.Trim().ToUpper();
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        narratorList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            NarratorUC narrator = new NarratorUC(reader.GetInt16(0), reader.GetString(1));
                            narratorList.Children.Add(narrator);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет дикторов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке дикторов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void SearchButtonTopics_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHTOPIC";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("PTOPICNAME", OracleDbType.Varchar2, 30).Value = searchBarTopics.Text.Trim().ToUpper();
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        topicList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            TopicUC topic = new TopicUC(reader.GetInt16(0), reader.GetString(2), reader.GetString(1), reader.GetInt16(3));
                            topicList.Children.Add(topic);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет подкастов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void AddNewPodcastButton_Click(object sender, RoutedEventArgs e)
        {
            AddNewPodcast addPodcastWin = new AddNewPodcast();
            addPodcastWin.PodcastAdded += OnPodcastAdded;
            addPodcastWin.Show();
            Application.Current.Windows[0].Hide();
        }

        private void SearchButtonPodcasts_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCAST";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("PPODCASTNAME", OracleDbType.Varchar2, 30).Value = searchBarPodcasts.Text.Trim().ToUpper();
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        podcastList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            PodcastUC podcast = new PodcastUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            podcastList.Children.Add(podcast);
                        }
                        if (count == 0)
                        {
                            MessageBox.Show("Нет подкастов для отображения.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }

        private void TableControlButton_Click(object sender, RoutedEventArgs e)
        {
            AdminWindow win = new AdminWindow();
            win.Show();
            Application.Current.Windows[0].Hide();
        }

        private void SearchButtonPlaylist_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                con.Open();
                using (OracleCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "SYS.SEARCHPODCASTBYPLAYLIST";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("PPODCASTNAME", OracleDbType.Varchar2, 30).Value = searchBarPlaylist.Text.Trim().ToUpper();
                    cmd.Parameters.Add("PUSERID", OracleDbType.Int32, 10).Value = DataWorker.CurrentUserId;
                    OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
                    cursorParam.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(cursorParam);
                    cmd.ExecuteNonQuery();
                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        playlistList.Children.Clear();
                        int count = 0;
                        while (reader.Read())
                        {
                            count++;
                            int podcastId = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            string podcastName = reader.IsDBNull(1) ? "Неизвестно" : reader.GetString(3);
                            string topicName = reader.IsDBNull(2) ? "Неизвестно" : reader.GetString(2);
                            string narratorName = reader.IsDBNull(3) ? "Неизвестно" : reader.GetString(1);
                            int topicYear = reader.IsDBNull(4) ? 0 : reader.GetInt16(4);
                            SavedUC podcast = new SavedUC(podcastId, podcastName, topicName, narratorName, (short)topicYear);
                            playlistList.Children.Add(podcast);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке подкастов: {ex.Message}\n{ex.StackTrace}");
            }
            finally
            {
                con.Close();
            }
        }
    }
}