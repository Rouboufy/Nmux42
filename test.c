/* ************************************************************************** */
/*																			*/
/*														:::	  ::::::::   */
/*   test.c                                             :+:      :+:    :+:   */
/*													+:+ +:+		 +:+	 */
/*   By: blanglai </var/spool/mail/blanglai>		+#+  +:+	   +#+		*/
/*												+#+#+#+#+#+   +#+		   */
/*   Created: 2026/05/26 17:03:49 by blanglai		  #+#	#+#			 */
/*   Updated: 2026/05/26 19:45:35 by blanglai         ###   ########.fr       */
/*																			*/
/* ************************************************************************** */

#include <stdio.h>

int	ft_strlen(char *str)
{
	int	len;

	len = 0;
	while (*str)
	{
		len++;
		str++;
	}
	return (len);
}

int	main(void)
{
	char	*str;

	*str = "Hello";
	ft_strlen(str);
	printf("%s", str);
}
